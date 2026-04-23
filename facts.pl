% system(SystemId).
system(marketing_bot).
system(meeting_summariser).
system(sales_agent).
system(hr_helper).

% control(Control).
control(owner_assigned).
control(in_inventory).
control(approved).
control(pii_guardrail).

% owner(SystemId, Owner).
owner(marketing_bot, marketing_team).
owner(sales_agent, sales_ops).
owner(hr_helper, hr_ops).

% inventory(SystemId).
inventory(marketing_bot).
inventory(sales_agent).
inventory(hr_helper).

% approved(SystemId).
approved(marketing_bot).
approved(sales_agent).
approved(hr_helper).

% capability(SystemId, Capability).
capability(marketing_bot, summarisation).
capability(meeting_summariser, summarisation).
capability(sales_agent, lead_scoring).
capability(hr_helper, document_qa).

% usesData(SystemId, DataId).
usesData(marketing_bot, customer_export).
usesData(meeting_summariser, meeting_notes).
usesData(sales_agent, crm_snapshot).
usesData(hr_helper, employee_files).

% dataClass(DataId, DataClass).
dataClass(customer_export, pii).
dataClass(meeting_notes, internal).
dataClass(crm_snapshot, pii).
dataClass(employee_files, pii).

% guardrail(SystemId, Guardrail).
guardrail(sales_agent, piiFiltering).
