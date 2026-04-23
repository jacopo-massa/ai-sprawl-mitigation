% Observations: obs(Fact, Source, Timestamp, Confidence)

obs(system(marketing_bot), casb_scan, date(2026,4,20), 0.96).
obs(system(meeting_summariser), browser_extension_scan, date(2026,4,21), 0.93).
obs(system(sales_agent), ai_registry, date(2026,4,18), 0.99).
obs(system(hr_helper), repo_scan, date(2026,4,20), 0.91).

obs(owner(marketing_bot, marketing_team), cmdb, date(2026,4,18), 0.99).
obs(owner(sales_agent, sales_ops), cmdb, date(2026,4,18), 0.99).
obs(owner(hr_helper, hr_ops), cmdb, date(2026,4,18), 0.99).
obs(no_owner(meeting_summariser), cmdb_audit, date(2026,4,21), 0.97).

obs(in_inventory(marketing_bot), ai_registry, date(2026,4,18), 0.99).
obs(in_inventory(sales_agent), ai_registry, date(2026,4,18), 0.99).
obs(in_inventory(hr_helper), ai_registry, date(2026,4,18), 0.99).
obs(not_in_inventory(meeting_summariser), registry_audit, date(2026,4,21), 0.97).

obs(approved(marketing_bot), governance_portal, date(2026,4,10), 0.98).
obs(approved(sales_agent), governance_portal, date(2026,4,10), 0.98).
obs(approved(hr_helper), governance_portal, date(2026,4,10), 0.98).
obs(not_approved(meeting_summariser), governance_audit, date(2026,4,21), 0.95).

obs(capability(marketing_bot, summarisation), repo_scan, date(2026,4,20), 0.91).
obs(capability(meeting_summariser, summarisation), browser_extension_scan, date(2026,4,21), 0.90).
obs(capability(sales_agent, lead_scoring), repo_scan, date(2026,4,20), 0.92).
obs(capability(hr_helper, document_qa), repo_scan, date(2026,4,20), 0.90).

obs(uses_data(marketing_bot, customer_export), dlp_scan, date(2026,4,20), 0.93).
obs(uses_data(meeting_summariser, meeting_notes), browser_extension_scan, date(2026,4,21), 0.89).
obs(uses_data(sales_agent, crm_snapshot), dlp_scan, date(2026,4,20), 0.93).
obs(uses_data(hr_helper, employee_files), dlp_scan, date(2026,4,20), 0.93).

obs(data_class(customer_export, pii), data_catalog, date(2026,4,15), 0.99).
obs(data_class(meeting_notes, internal), data_catalog, date(2026,4,15), 0.99).
obs(data_class(crm_snapshot, pii), data_catalog, date(2026,4,15), 0.99).
obs(data_class(employee_files, pii), data_catalog, date(2026,4,15), 0.99).

obs(guardrail(marketing_bot, none), control_scan, date(2026,4,20), 0.92).
obs(guardrail(sales_agent, pii_filtering), control_scan, date(2026,4,20), 0.95).