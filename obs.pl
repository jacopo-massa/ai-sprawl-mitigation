obs(marketing_bot, system, casb_scan, date(2026,4,20), 0.96).
obs(meeting_summariser, system, browser_extension_scan, date(2026,4,21), 0.93).
obs(sales_agent, system, ai_registry, date(2026,4,18), 0.99).
obs(hr_helper, system, repo_scan, date(2026,4,20), 0.91).

obs(marketing_bot, owner(marketing_team), cmdb, date(2026,4,18), 0.99).
obs(sales_agent, owner(sales_ops), cmdb, date(2026,4,18), 0.99).
obs(hr_helper, owner(hr_ops), cmdb, date(2026,4,18), 0.99).

obs(marketing_bot, in_inventory, ai_registry, date(2026,4,18), 0.99).
obs(sales_agent, in_inventory, ai_registry, date(2026,4,18), 0.99).
obs(hr_helper, in_inventory, ai_registry, date(2026,4,18), 0.99).

obs(marketing_bot, approved, governance_portal, date(2026,4,10), 0.98).
obs(sales_agent, approved, governance_portal, date(2026,4,10), 0.98).
obs(hr_helper, approved, governance_portal, date(2026,4,10), 0.98).

obs(marketing_bot, capability(summarisation), repo_scan, date(2026,4,20), 0.91).
obs(meeting_summariser, capability(summarisation), browser_extension_scan, date(2026,4,21), 0.90).
obs(sales_agent, capability(lead_scoring), repo_scan, date(2026,4,20), 0.92).
obs(hr_helper, capability(document_qa), repo_scan, date(2026,4,20), 0.90).

obs(marketing_bot, usesData(customer_export), dlp_scan, date(2026,4,20), 0.93).
obs(meeting_summariser, usesData(meeting_notes), browser_extension_scan, date(2026,4,21), 0.89).
obs(sales_agent, usesData(crm_snapshot), dlp_scan, date(2026,4,20), 0.93).
obs(hr_helper, usesData(employee_files), dlp_scan, date(2026,4,20), 0.93).

obs(customer_export, dataClass(pii), data_catalog, date(2026,4,15), 0.99).
obs(meeting_notes, dataClass(internal), data_catalog, date(2026,4,15), 0.99).
obs(crm_snapshot, dataClass(pii), data_catalog, date(2026,4,15), 0.99).
obs(employee_files, dataClass(pii), data_catalog, date(2026,4,15), 0.99).

obs(sales_agent, guardrail(piiFiltering), control_scan, date(2026,4,20), 0.95).


% ---------- Evidence policy ----------

% Minimum confidence required to accept an observation.
minConfidence(0.90).

% Source-specific trust model.
% A source may be trusted only for certain assertion types.

trustedSourceFor(ai_registry, system).
trustedSourceFor(ai_registry, in_inventory).
trustedSourceFor(ai_registry, not_in_inventory).

trustedSourceFor(cmdb, owner(_)).
trustedSourceFor(cmdb, no_owner).

trustedSourceFor(governance_portal, approved).
trustedSourceFor(governance_portal, not_approved).

trustedSourceFor(repo_scan, system).
trustedSourceFor(repo_scan, capability(_)).

trustedSourceFor(casb_scan, system).

trustedSourceFor(browser_extension_scan, system).
trustedSourceFor(browser_extension_scan, capability(_)).
trustedSourceFor(browser_extension_scan, usesData(_)).

% Data Loss Prevention
trustedSourceFor(dlp_scan, usesData(_)).

trustedSourceFor(data_catalog, dataClass(_)).

trustedSourceFor(control_scan, guardrail(_)).

% A system observed by indirect discovery sources but not present in inventory
% is treated as a possible shadow-AI candidate.

% Cloud Access Security Broker scans can reveal unsanctioned SaaS usage
discoverySource(casb_scan). 
% browser extensions can reveal AI tools being used by employees that haven't been formally onboarded
discoverySource(browser_extension_scan). 
% code repositories can reveal AI tools in development or use that haven't been formally onboarded
discoverySource(repo_scan).

% For now, freshness is permissive.
% This can later be replaced with policy-specific freshness thresholds.
fresh(_).
