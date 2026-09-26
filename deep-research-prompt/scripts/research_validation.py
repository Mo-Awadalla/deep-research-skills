"""Strict offline schema and recorded-completion checks; never truth certification."""
from __future__ import annotations
import json
import re
import sys
from datetime import date
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

try:
    import yaml
except ImportError:
    print('BLOCKED: Python 3 and PyYAML are required (python3 -m pip install PyYAML)', file=sys.stderr)
    raise SystemExit(2)


class SchemaError(ValueError):
    pass


class UniqueLoader(yaml.SafeLoader):
    pass


def unique_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if not isinstance(key, str):
            raise SchemaError('YAML mapping keys must be strings; merge keys are unsupported')
        if key in result:
            raise SchemaError(f'duplicate YAML key: {key}')
        result[key] = loader.construct_object(value_node, deep=deep)
    return result


UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def document(path, key):
    text = Path(path).read_text(encoding='utf-8')
    blocks = re.findall(r'(?m)^\s*```(?:yaml|yml)\s*\n(.*?)^\s*```\s*$', text, re.S)
    if not blocks and re.match(rf'\s*{re.escape(key)}\s*:', text):
        blocks = [text]
    matches = []
    for block in blocks:
        try:
            value = yaml.load(block, Loader=UniqueLoader)
        except (yaml.YAMLError, SchemaError) as exc:
            raise SchemaError(f'invalid YAML in {path}: {exc}') from exc
        if isinstance(value, dict) and key in value:
            if set(value) != {key}:
                raise SchemaError(f'{key} block must contain only the {key} root key')
            matches.append(value[key])
    if len(matches) != 1:
        raise SchemaError(f'expected exactly one {key} YAML block; found {len(matches)}')
    return matches[0]


def narrative_refs(path, value):
    """C/E identifiers are reserved in prose; fenced code examples are excluded."""
    text = Path(path).read_text(encoding='utf-8')
    text = re.sub(r'(?ms)^\s*```[^\n]*\n.*?^\s*```\s*$', '', text)
    known = {item['id'] for key in ('claims', 'evidence') for item in value[key]}
    mentioned = set(re.findall(r'(?<![A-Za-z0-9_])[CE][0-9]+(?![A-Za-z0-9_])', text))
    if mentioned - known:
        raise SchemaError(f'narrative references unknown IDs: {sorted(mentioned - known)}')


def mapping(value, required, optional=(), where='record'):
    if not isinstance(value, dict):
        raise SchemaError(f'{where}: expected mapping')
    missing, extra = set(required) - set(value), set(value) - set(required) - set(optional)
    if missing or extra:
        raise SchemaError(f'{where}: missing {sorted(missing)}; unknown {sorted(extra)}')
    return value


def string(value, where, empty=False):
    if not isinstance(value, str) or (not empty and not value.strip()):
        raise SchemaError(f'{where}: expected {"possibly empty " if empty else "nonempty "}string')


def sequence(value, where, nonempty=False):
    if not isinstance(value, list) or (nonempty and not value):
        raise SchemaError(f'{where}: expected {"nonempty " if nonempty else ""}list')
    return value


def strings(value, where, nonempty=False):
    for item in sequence(value, where, nonempty):
        string(item, where)
    if len(set(value)) != len(value):
        raise SchemaError(f'{where}: duplicate entries')


def choice(value, choices, where):
    if not isinstance(value, str) or value not in choices:
        raise SchemaError(f'{where}: expected one of {", ".join(choices)}')


def boolean(value, where):
    if type(value) is not bool:
        raise SchemaError(f'{where}: expected boolean')


def positive(value, where):
    if type(value) is not int or value < 1:
        raise SchemaError(f'{where}: expected positive integer')


def iso_date(value, where, nullable=False):
    if value is None and nullable:
        return
    if type(value) is date:
        return
    try:
        if not isinstance(value, str) or not re.fullmatch(r'\d{4}-\d{2}-\d{2}', value):
            raise ValueError()
        date.fromisoformat(value)
    except ValueError:
        raise SchemaError(f'{where}: expected ISO date YYYY-MM-DD' + (' or null' if nullable else ''))


def index(items, prefix, where):
    result = {}
    for item in sequence(items, where):
        if not isinstance(item, dict):
            raise SchemaError(f'{where}: entries must be mappings')
        key = item.get('id')
        if not isinstance(key, str) or not re.fullmatch(prefix + r'[1-9][0-9]*', key):
            raise SchemaError(f'{where}: expected {prefix}1-style ID; got {key!r}')
        if key in result:
            raise SchemaError(f'{where}: duplicate ID {key}')
        result[key] = item
    return result


def refs(values, known, where, nonempty=False):
    strings(values, where, nonempty)
    if set(values) - set(known):
        raise SchemaError(f'{where}: unknown IDs {sorted(set(values) - set(known))}')


def source_key(evidence):
    if 'attachment_id' in evidence:
        return 'attachment:' + evidence['attachment_id'].strip()
    parts = urlsplit(evidence['url'])
    query = [(k, v) for k, v in parse_qsl(parts.query, keep_blank_values=True)
             if not k.lower().startswith('utm_')]
    host = parts.hostname.lower()
    if parts.port not in (None, 80, 443):
        host += f':{parts.port}'
    return urlunsplit(('https', host, parts.path.rstrip('/'), urlencode(sorted(query)), ''))


def url(value, where):
    string(value, where)
    try:
        parts = urlsplit(value)
        _ = parts.port
        valid = parts.scheme in ('http', 'https') and bool(parts.hostname)
        valid = valid and not parts.username and not parts.password and not re.search(r'\s', value)
    except ValueError:
        valid = False
    if not valid:
        raise SchemaError(f'{where}: expected HTTP(S) source URL without credentials')


def contract(value):
    value = dict(mapping(value, ('schema_version', 'artifact_kind', 'required_criteria'),
                         ('required_cycles', 'consequential', 'require_synthesis'), 'acceptance'))
    value.setdefault('required_cycles', 5)
    value.setdefault('consequential', False)
    value.setdefault('require_synthesis', False)
    if type(value['schema_version']) is not int or value['schema_version'] != 1:
        raise SchemaError('acceptance.schema_version: supported version is 1')
    choice(value['artifact_kind'], ('report', 'handoff'), 'acceptance.artifact_kind')
    positive(value['required_cycles'], 'acceptance.required_cycles')
    strings(value['required_criteria'], 'acceptance.required_criteria', True)
    boolean(value['consequential'], 'acceptance.consequential')
    boolean(value['require_synthesis'], 'acceptance.require_synthesis')
    return value


def phase_fields(item, where):
    for field in ('id', 'revision', 'actor', 'summary'):
        string(item[field], where + '.' + field)
    choice(item['status'], ('completed', 'blocked'), where + '.status')


def audit_fields(item, where, reaudit=False):
    required = ('id', 'status', 'revision', 'actor', 'summary', 'independent', 'criteria', 'finding_ids')
    mapping(item, required + (('after_repair',) if reaudit else ()), where=where)
    phase_fields(item, where)
    boolean(item['independent'], where + '.independent')
    seen = set()
    for criterion in sequence(item['criteria'], where + '.criteria'):
        mapping(criterion, ('id', 'status'), where=where + '.criteria')
        string(criterion['id'], where + '.criteria.id')
        if criterion['id'] in seen:
            raise SchemaError(f'{where}: duplicate criterion {criterion["id"]}')
        seen.add(criterion['id'])
        choice(criterion['status'], ('passed', 'failed', 'blocked'), where + '.criteria.status')
    strings(item['finding_ids'], where + '.finding_ids')
    if reaudit:
        string(item['after_repair'], where + '.after_repair')


def repair_fields(item, where, additional=False):
    required = ('id', 'status', 'input_revision', 'revision', 'actor', 'summary', 'changed', 'no_change_reason')
    mapping(item, required + (('cycle', 'after_audit') if additional else ()), where=where)
    phase_fields(item, where)
    string(item['input_revision'], where + '.input_revision')
    boolean(item['changed'], where + '.changed')
    string(item['no_change_reason'], where + '.no_change_reason', empty=item['changed'])
    if item['changed'] == (item['revision'] == item['input_revision']):
        raise SchemaError(f'{where}: changed flag and input/output revisions disagree')
    if additional:
        positive(item['cycle'], where + '.cycle')
        string(item['after_audit'], where + '.after_audit')


def state(value):
    required = ('schema_version', 'artifact_kind', 'revision', 'claims', 'evidence', 'support_edges', 'leads',
                'coverage', 'stopping', 'findings', 'contributions', 'run_manifest')
    mapping(value, required, ('handoff',), 'research_state')
    if type(value['schema_version']) is not int or value['schema_version'] != 1:
        raise SchemaError('research_state.schema_version: supported version is 1')
    choice(value['artifact_kind'], ('report', 'handoff'), 'research_state.artifact_kind')
    string(value['revision'], 'research_state.revision')
    claims = index(value['claims'], 'C', 'claims')
    evidence = index(value['evidence'], 'E', 'evidence')
    leads = index(value['leads'], 'L', 'leads')
    findings = index(value['findings'], 'F', 'findings')
    contributions = index(value['contributions'], 'S', 'contributions')
    for claim in claims.values():
        mapping(claim, ('id', 'text', 'kind', 'material', 'status'), ('single_source_exception',), claim['id'])
        string(claim['text'], claim['id'] + '.text')
        choice(claim['kind'], ('fact', 'inference', 'forecast', 'recommendation'), claim['id'] + '.kind')
        choice(claim['status'], ('supported', 'unknown'), claim['id'] + '.status')
        boolean(claim['material'], claim['id'] + '.material')
        if 'single_source_exception' in claim:
            string(claim['single_source_exception'], claim['id'] + '.single_source_exception')
    roots = {}
    for ev in evidence.values():
        mapping(ev, ('id', 'title', 'source_class', 'independence_group', 'access', 'published_at', 'accessed_at'), ('url', 'attachment_id'), ev['id'])
        if ('url' in ev) == ('attachment_id' in ev):
            raise SchemaError(f'{ev["id"]}: require exactly one of url or attachment_id')
        if 'url' in ev:
            url(ev['url'], ev['id'] + '.url')
        else:
            string(ev['attachment_id'], ev['id'] + '.attachment_id')
        for field in ('title', 'independence_group'):
            string(ev[field], ev['id'] + '.' + field)
        choice(ev['source_class'], ('primary', 'secondary', 'practitioner', 'vendor', 'other'), ev['id'] + '.source_class')
        choice(ev['access'], ('retrieved', 'limited', 'unavailable'), ev['id'] + '.access')
        iso_date(ev['published_at'], ev['id'] + '.published_at', nullable=True)
        iso_date(ev['accessed_at'], ev['id'] + '.accessed_at')
        key = source_key(ev)
        if key in roots and roots[key] != ev['independence_group']:
            raise SchemaError(f'{ev["id"]}: same source relabeled as independent groups')
        roots[key] = ev['independence_group']
    seen_edges = set()
    for edge in sequence(value['support_edges'], 'support_edges'):
        mapping(edge, ('claim_id', 'evidence_id', 'relation', 'locator', 'checked_by'), where='support edge')
        refs([edge['claim_id']], claims, 'support edge claim')
        refs([edge['evidence_id']], evidence, 'support edge evidence')
        key = (edge['claim_id'], edge['evidence_id'])
        if key in seen_edges:
            raise SchemaError(f'duplicate support edge: {key}')
        seen_edges.add(key)
        choice(edge['relation'], ('supports', 'partially_supports', 'contradicts', 'context_only', 'inaccessible'), 'support edge relation')
        string(edge['locator'], 'support edge locator', empty=edge['relation'] == 'inaccessible')
        string(edge['checked_by'], 'support edge checked_by')
        if edge['relation'] == 'supports' and evidence[edge['evidence_id']]['access'] != 'retrieved':
            raise SchemaError('full support cannot be attributed to evidence not retrieved')
    for lead in leads.values():
        mapping(lead, ('id', 'url', 'description', 'status'), where=lead['id'])
        url(lead['url'], lead['id'] + '.url')
        string(lead['description'], lead['id'] + '.description')
        choice(lead['status'], ('unverified', 'investigated'), lead['id'] + '.status')
    coverage_ids = set()
    for item in sequence(value['coverage'], 'coverage'):
        mapping(item, ('criterion', 'status', 'claim_ids'), where='coverage')
        string(item['criterion'], 'coverage.criterion')
        if item['criterion'] in coverage_ids:
            raise SchemaError('duplicate coverage criterion')
        coverage_ids.add(item['criterion'])
        choice(item['status'], ('met', 'unresolved'), 'coverage.status')
        refs(item['claim_ids'], claims, 'coverage.claim_ids')
    mapping(value['stopping'], ('reason', 'remaining_gaps', 'blocked_on'), where='stopping')
    string(value['stopping']['reason'], 'stopping.reason')
    strings(value['stopping']['remaining_gaps'], 'stopping.remaining_gaps')
    strings(value['stopping']['blocked_on'], 'stopping.blocked_on')
    for finding in findings.values():
        mapping(finding, ('id', 'severity', 'status', 'description', 'resolution', 'resolved_revision'), where=finding['id'])
        choice(finding['severity'], ('material', 'minor'), finding['id'] + '.severity')
        choice(finding['status'], ('open', 'resolved'), finding['id'] + '.status')
        string(finding['description'], finding['id'] + '.description')
        string(finding['resolution'], finding['id'] + '.resolution', empty=finding['status'] == 'open')
        if finding['status'] == 'resolved':
            string(finding['resolved_revision'], finding['id'] + '.resolved_revision')
        elif finding['resolved_revision'] is not None:
            raise SchemaError(f'{finding["id"]}: open finding cannot have resolved_revision')
    for item in contributions.values():
        mapping(item, ('id', 'claim_id', 'proposition', 'prior_work_evidence_ids', 'difference', 'falsification_test', 'status'), where=item['id'])
        refs([item['claim_id']], claims, item['id'] + '.claim_id')
        refs(item['prior_work_evidence_ids'], evidence, item['id'] + '.prior_work_evidence_ids', True)
        for field in ('proposition', 'difference', 'falsification_test'):
            string(item[field], item['id'] + '.' + field)
        choice(item['status'], ('proposed', 'derived', 'tested', 'replicated'), item['id'] + '.status')
    manifest = mapping(value['run_manifest'], ('requested_cycles', 'cycles', 'additional_repairs', 'reaudits', 'attestations'), where='run_manifest')
    positive(manifest['requested_cycles'], 'run_manifest.requested_cycles')
    calls, repairs, audits, dependencies = {}, {}, {}, {}
    def add_call(item, dependency=None):
        if item['id'] in calls:
            raise SchemaError(f'duplicate run ID {item["id"]}')
        calls[item['id']] = item
        dependencies[item['id']] = dependency
    numbers = []
    for cycle in sequence(manifest['cycles'], 'cycles'):
        mapping(cycle, ('number', 'research', 'audit', 'repair'), where='cycle')
        positive(cycle['number'], 'cycle.number')
        numbers.append(cycle['number'])
        mapping(cycle['research'], ('id', 'status', 'revision', 'actor', 'summary'), where='research')
        phase_fields(cycle['research'], 'research')
        audit_fields(cycle['audit'], 'audit')
        repair_fields(cycle['repair'], 'repair')
        if cycle['research']['revision'] != cycle['audit']['revision'] or cycle['audit']['revision'] != cycle['repair']['input_revision']:
            raise SchemaError(f'cycle {cycle["number"]}: research/audit/repair revision chain disagrees')
        add_call(cycle['research'])
        add_call(cycle['audit'], cycle['research']['id'])
        add_call(cycle['repair'], cycle['audit']['id'])
        repairs[cycle['repair']['id']] = cycle['repair']
        audits[cycle['audit']['id']] = cycle['audit']
    if numbers != list(range(1, len(numbers) + 1)):
        raise SchemaError('cycles must be unique, ordered, and contiguous from 1')
    for repair in sequence(manifest['additional_repairs'], 'additional_repairs'):
        repair_fields(repair, 'additional repair', True)
        if repair['cycle'] not in numbers:
            raise SchemaError('additional repair refers to nonexistent cycle')
        add_call(repair, repair['after_audit'])
        repairs[repair['id']] = repair
    for audit in sequence(manifest['reaudits'], 'reaudits'):
        audit_fields(audit, 'reaudit', True)
        add_call(audit, audit['after_repair'])
        audits[audit['id']] = audit
        if audit['after_repair'] not in repairs or audit['revision'] != repairs[audit['after_repair']]['revision']:
            raise SchemaError('reaudit must reference a repair of the same revision')
    for repair in manifest['additional_repairs']:
        prior = audits.get(repair['after_audit'])
        if prior is None or prior['revision'] != repair['input_revision']:
            raise SchemaError('additional repair must follow an audit of its input revision')
    seen_revisions = set()
    for cycle in manifest['cycles']:
        seen_revisions.add(cycle['research']['revision'])
        cycle_repairs = [cycle['repair']] + [item for item in manifest['additional_repairs'] if item['cycle'] == cycle['number']]
        current = cycle['research']['revision']
        for repair in cycle_repairs:
            if repair['input_revision'] != current:
                raise SchemaError('additional repairs must form one ordered revision chain per cycle')
            if repair['changed'] and repair['revision'] in seen_revisions:
                raise SchemaError('changed repair must create a new immutable revision, never reuse an earlier version')
            seen_revisions.add(repair['revision'])
            current = repair['revision']
    for call_id in dependencies:
        visited, current = set(), call_id
        while current is not None:
            if current in visited:
                raise SchemaError('circular run dependencies')
            visited.add(current)
            current = dependencies[current]
    known_revisions = {value['revision']} | {item['revision'] for item in calls.values()}
    for finding in findings.values():
        if finding['status'] == 'resolved' and finding['resolved_revision'] not in known_revisions:
            raise SchemaError(f'{finding["id"]}: unknown resolved revision')
    for audit in audits.values():
        refs(audit['finding_ids'], findings, audit['id'] + '.finding_ids')
    attestation_ids = set()
    for item in sequence(manifest['attestations'], 'attestations'):
        mapping(item, ('id', 'kind', 'method', 'by', 'statement', 'status'), where='attestation')
        for field in ('id', 'by', 'statement'):
            string(item[field], 'attestation.' + field)
        if item['id'] in attestation_ids:
            raise SchemaError('duplicate attestation ID')
        attestation_ids.add(item['id'])
        choice(item['kind'], ('capability', 'external_handoff'), 'attestation.kind')
        choice(item['method'], ('manual',), 'attestation.method')
        choice(item['status'], ('confirmed', 'unavailable'), 'attestation.status')
    if value['artifact_kind'] == 'handoff':
        packet = mapping(value.get('handoff'), ('objective', 'questions', 'constraints', 'expected_artifacts', 'capabilities', 'acceptance_criteria', 'continuation', 'controller', 'stage_prompts', 'attachments', 'future_dependencies'), where='handoff')
        for field in ('objective', 'continuation', 'controller'):
            string(packet[field], 'handoff.' + field)
        for field in ('questions', 'constraints', 'expected_artifacts', 'capabilities', 'acceptance_criteria'):
            strings(packet[field], 'handoff.' + field, nonempty=field != 'constraints')
        strings(packet['future_dependencies'], 'handoff.future_dependencies')
        mapping(packet['stage_prompts'], ('research', 'audit', 'repair'), where='handoff.stage_prompts')
        for phase, prompt in packet['stage_prompts'].items():
            string(prompt, 'handoff.stage_prompts.' + phase)
        attachment_ids = set()
        for attachment in sequence(packet['attachments'], 'handoff.attachments'):
            mapping(attachment, ('id', 'status', 'description'), where='handoff attachment')
            string(attachment['id'], 'handoff attachment.id')
            if attachment['id'] in attachment_ids:
                raise SchemaError('duplicate handoff attachment ID')
            attachment_ids.add(attachment['id'])
            string(attachment['description'], 'handoff attachment.description')
            choice(attachment['status'], ('supplied', 'embedded', 'missing'), 'handoff attachment.status')
    elif 'handoff' in value:
        raise SchemaError('report must not contain a handoff packet')
    return value


def assess(value, rules):
    """Evaluate recorded approvals, not the truth of the recorded statements."""
    blocked, repair = [], []
    manifest = value['run_manifest']
    if value['artifact_kind'] != rules['artifact_kind'] and not (rules['artifact_kind'] == 'handoff' and value['artifact_kind'] == 'report'):
        raise SchemaError('artifact_kind differs between contract and artifact')
    if manifest['requested_cycles'] != rules['required_cycles']:
        repair.append('requested cycle count differs from governing contract')
    if value['artifact_kind'] == 'handoff':
        if set(value['handoff']['acceptance_criteria']) != set(rules['required_criteria']):
            blocked.append('handoff acceptance criterion IDs differ from contract')
        if any(item['status'] == 'missing' for item in value['handoff']['attachments']):
            blocked.append('an initial handoff attachment is missing')
        return outcome(blocked, repair, value, rules, handoff=True)
    if len(manifest['cycles']) != rules['required_cycles']:
        repair.append('all requested research-audit-repair cycles have not been recorded')
    blocked.extend(value['stopping']['blocked_on'])
    calls, audits, repairs = [], [], []
    for cycle in manifest['cycles']:
        calls.extend(cycle[phase] for phase in ('research', 'audit', 'repair'))
        audit = cycle['audit']
        audits.append(audit)
        repairs.append(cycle['repair'])
        if not audit['independent'] or audit['actor'] == cycle['research']['actor']:
            repair.append(f'{audit["id"]}: independent review is not attested')
    calls.extend(manifest['additional_repairs'])
    calls.extend(manifest['reaudits'])
    repairs.extend(manifest['additional_repairs'])
    audits.extend(manifest['reaudits'])
    for call in calls:
        if call['status'] != 'completed':
            blocked.append(f'{call["id"]}: run is not completed')
    for audit in audits:
        if set(item['id'] for item in audit['criteria']) != set(rules['required_criteria']):
            repair.append(f'{audit["id"]}: criterion IDs differ from governing contract')
        if not audit['independent']:
            repair.append(f'{audit["id"]}: independent review is not attested')
    for audit in manifest['reaudits']:
        prior = next(item for item in repairs if item['id'] == audit['after_repair'])
        if audit['actor'] == prior['actor']:
            repair.append(f'{audit["id"]}: reviewer is the repair actor')
    for edited in repairs:
        if edited['changed'] and not any(audit['revision'] == edited['revision'] and audit['independent']
                                         and audit['status'] == 'completed' and audit['actor'] != edited['actor']
                                         for audit in audits):
            repair.append(f'{edited["id"]}: changed revision has no independent re-audit')
    final_repair = None
    if manifest['cycles']:
        last_cycle = manifest['cycles'][-1]
        final_repair = last_cycle['repair']
        for extra in manifest['additional_repairs']:
            if extra['cycle'] == last_cycle['number']:
                final_repair = extra
        if final_repair['revision'] != value['revision']:
            repair.append('current artifact revision differs from final repair output')
    # Revision IDs identify immutable report+evidence+criteria snapshots. A no-op
    # preserves a current audit; edited content requires an audit of its version.
    final_audits = [item for item in audits if item['revision'] == value['revision']
                    and item['status'] == 'completed' and item['independent']
                    and (final_repair is None or item['actor'] != final_repair['actor'])]
    if not final_audits:
        repair.append('current revision has no completed independent audit')
    elif any(item['status'] != 'passed' for audit in final_audits for item in audit['criteria']):
        repair.append('current revision has a failed or blocked required criterion')
    material_findings = {item['id'] for item in value['findings'] if item['severity'] == 'material'}
    if final_audits and not any(material_findings <= set(audit['finding_ids']) for audit in final_audits):
        repair.append('current revision audit does not account for every material finding')
    for finding in value['findings']:
        if finding['severity'] != 'material' or finding['status'] != 'resolved':
            continue
        revision = finding['resolved_revision']
        authors = {item['actor'] for item in repairs if item['revision'] == revision}
        authors.update(cycle['research']['actor'] for cycle in manifest['cycles'] if cycle['research']['revision'] == revision)
        if not any(audit['revision'] == revision and audit['status'] == 'completed' and audit['independent']
                   and audit['actor'] not in authors and finding['id'] in audit['finding_ids'] for audit in audits):
            repair.append(f'{finding["id"]}: resolution has no independent finding-specific audit of its revision')
    coverage = {item['criterion']: item for item in value['coverage']}
    if set(coverage) != set(rules['required_criteria']):
        repair.append('coverage criterion IDs differ from governing contract')
    elif any(item['status'] != 'met' for item in coverage.values()):
        repair.append('required coverage remains unresolved')
    if any(item['severity'] == 'material' and item['status'] == 'open' for item in value['findings']):
        repair.append('material findings remain open')
    claims = {item['id']: item for item in value['claims']}
    evidence = {item['id']: item for item in value['evidence']}
    if not claims:
        repair.append('report has no registered claims')
    for claim in claims.values():
        if claim['status'] == 'unknown':
            if claim['material']:
                repair.append(f'{claim["id"]}: material claim is unknown')
            continue
        supporting = [evidence[edge['evidence_id']] for edge in value['support_edges']
                      if edge['claim_id'] == claim['id'] and edge['relation'] == 'supports']
        if not supporting:
            repair.append(f'{claim["id"]}: supported claim lacks a checked support edge')
        if rules['consequential'] and claim['material']:
            qualified = [ev for ev in supporting if ev['source_class'] in ('primary', 'secondary')]
            groups = set(ev['independence_group'] for ev in qualified)
            if not qualified or (len(groups) < 2 and not claim.get('single_source_exception')):
                repair.append(f'{claim["id"]}: consequential claim lacks independent authoritative support or documented single-source exception')
    if rules['require_synthesis'] and not value['contributions']:
        repair.append('required structured contribution record is missing')
    attestations = manifest['attestations']
    if not any(item['kind'] == 'capability' and item['status'] == 'confirmed' for item in attestations):
        blocked.append('execution capability has no recorded manual attestation')
    if any(item['status'] == 'unavailable' for item in attestations):
        blocked.append('a required capability or external handoff is recorded unavailable')
    return outcome(blocked, repair, value, rules)


def outcome(blocked, repair, value, rules, handoff=False):
    manifest = value['run_manifest']
    baseline = [cycle[phase] for cycle in manifest['cycles'] for phase in ('research', 'audit', 'repair')]
    extras = manifest['additional_repairs'] + manifest['reaudits']
    status = 'BLOCKED' if blocked else 'REPAIR_REQUIRED' if repair else 'PASS'
    return {'structure': 'VALID', 'status': status, 'approval_scope': 'handoff_packet_readiness' if handoff else 'recorded_report_acceptance',
            'research_complete': status == 'PASS' and not handoff,
            'requested_cycles': rules['required_cycles'], 'baseline_calls_required': 3 * rules['required_cycles'],
            'completed_baseline_calls': sum(call['status'] == 'completed' for call in baseline),
            'completed_extra_calls': sum(call['status'] == 'completed' for call in extras),
            'issues': blocked + repair,
            'limitation': 'Offline consistency checks of recorded attestations. Source truth, real execution, independence, and semantic quality require human/agent audit; they are not tool-certified.'}


def main(structure_only=False):
    args = sys.argv[1:]
    if len(args) not in ((1,) if structure_only else (1, 2)):
        print('Usage: validate-evidence-state.py REPORT.md' if structure_only else 'Usage: verify-deep-research-output.sh REPORT.md [CONTRACT.md]', file=sys.stderr)
        return 2
    try:
        value = state(document(args[0], 'research_state'))
        narrative_refs(args[0], value)
        if structure_only:
            print(json.dumps({'structure': 'VALID', 'approval': 'NOT_ASSESSED', 'limitation': 'Structure only; research completion and source truth are not established.'}, ensure_ascii=False, indent=2))
            return 0
        if len(args) == 1:
            result = {'structure': 'VALID', 'status': 'BLOCKED', 'research_complete': False,
                      'issues': ['A governing CONTRACT.md is required to assess approval.']}
        else:
            result = assess(value, contract(document(args[1], 'acceptance')))
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return {'PASS': 0, 'REPAIR_REQUIRED': 1, 'BLOCKED': 2}[result['status']]
    except (SchemaError, OSError, UnicodeError) as exc:
        print(json.dumps({'structure': 'INVALID', 'status': 'BLOCKED', 'research_complete': False, 'issues': [str(exc)]}, ensure_ascii=False, indent=2))
        return 2
