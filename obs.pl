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
