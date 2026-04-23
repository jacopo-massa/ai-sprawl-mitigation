:-['obs.pl'].

minConfidence(0.85).

% ---------- Main query ----------

report(S, OverallStatus, Controls, Findings, Actions, Redundancies) :- 
    % reportSystem(S),
    system(S),
    overallStatus(S, OverallStatus),
    sorted(control(Control, Status), controlSnapshot(S, Control, Status), Controls),
    sorted(finding(Severity, Code), finding(S, Severity, Code), Findings),
    sorted(Action, action(S, Action), Actions),
    sorted(Redundancy, redundancy(S, Redundancy), Redundancies).

% ---------- Consolidation ----------

reliable(Fact) :- obs(Fact, _, _, Confidence),
    minConfidence(MinConfidence),
    Confidence >= MinConfidence.

sorted(Template, Goal, Sorted) :- findall(Template, Goal, Results), sort(Results, Sorted).

system(S) :- reliable(system(S)).

reportSystem(S) :- sorted(System, system(System), Systems), member(S, Systems).

hasOwner(S) :- reliable(owner(S, _)).
noOwner(S) :- reliable(no_owner(S)).
inventoryYes(S) :- reliable(in_inventory(S)).
inventoryNo(S) :- reliable(not_in_inventory(S)).
approvedYes(S) :- reliable(approved(S)).
approvedNo(S) :- reliable(not_approved(S)).
guardrailYes(S) :- reliable(guardrail(S, pii_filtering)).
guardrailNo(S) :- reliable(guardrail(S, none)).

usesPii(S) :- reliable(uses_data(S, D)), reliable(data_class(D, pii)).

mandatoryControl(owner_assigned).
mandatoryControl(in_inventory).
mandatoryControl(approved).
mandatoryControl(pii_guardrail).

% ---------- Control evaluation ----------

controlStatus(S, owner_assigned, conflict) :- hasOwner(S), noOwner(S).
controlStatus(S, owner_assigned, pass) :- hasOwner(S), \+ noOwner(S).
controlStatus(S, owner_assigned, fail) :- noOwner(S), \+ hasOwner(S).
controlStatus(S, owner_assigned, unknown) :- system(S), \+ hasOwner(S), \+ noOwner(S).

controlStatus(S, in_inventory, conflict) :- inventoryYes(S), inventoryNo(S).
controlStatus(S, in_inventory, pass) :- inventoryYes(S), \+ inventoryNo(S).
controlStatus(S, in_inventory, fail) :- inventoryNo(S), \+ inventoryYes(S).
controlStatus(S, in_inventory, unknown) :- system(S), \+ inventoryYes(S), \+ inventoryNo(S).

controlStatus(S, approved, conflict) :- approvedYes(S), approvedNo(S).
controlStatus(S, approved, pass) :- approvedYes(S), \+ approvedNo(S).
controlStatus(S, approved, fail) :- approvedNo(S), \+ approvedYes(S).
controlStatus(S, approved, unknown) :- system(S), \+ approvedYes(S), \+ approvedNo(S).

controlStatus(S, pii_guardrail, not_applicable) :- system(S), \+ usesPii(S).
controlStatus(S, pii_guardrail, conflict) :- usesPii(S), guardrailYes(S), guardrailNo(S).
controlStatus(S, pii_guardrail, pass) :- usesPii(S), guardrailYes(S), \+ guardrailNo(S).
controlStatus(S, pii_guardrail, fail) :- usesPii(S), guardrailNo(S), \+ guardrailYes(S).
controlStatus(S, pii_guardrail, unknown) :- usesPii(S), \+ guardrailYes(S), \+ guardrailNo(S).

duplicateCapability(S1, S2, Capability) :- 
    system(S1), system(S2), S1 @< S2,
    reliable(capability(S1, Capability)),
    reliable(capability(S2, Capability)).

% ---------- Findings ----------

finding(S, high, pii_without_guardrail) :- controlStatus(S, pii_guardrail, fail).

finding(S, medium, no_owner) :- controlStatus(S, owner_assigned, fail).
finding(S, medium, not_in_inventory) :- controlStatus(S, in_inventory, fail).
finding(S, medium, not_approved) :- controlStatus(S, approved, fail).
finding(S, medium, control_unknown(pii_guardrail)) :- controlStatus(S, pii_guardrail, unknown).
finding(S, medium, conflicting_evidence(Control)) :- 
    mandatoryControl(Control),
    controlStatus(S, Control, conflict).
finding(S, low, control_unknown(Control)) :- 
    mandatoryControl(Control),
    Control \= pii_guardrail,
    controlStatus(S, Control, unknown).
finding(S, low, duplicate_capability(Other, Capability)) :- redundancy(S, redundant_with(Other, Capability)).

% ---------- Actions ----------

action(S, add_pii_guardrail) :- controlStatus(S, pii_guardrail, fail).
action(S, assign_owner) :- controlStatus(S, owner_assigned, fail).
action(S, register_in_inventory) :- controlStatus(S, in_inventory, fail).
action(S, submit_for_approval) :- controlStatus(S, approved, fail).

action(S, verify_control(Control)) :- mandatoryControl(Control), controlStatus(S, Control, unknown).
action(S, reconcile_sources(Control)) :- mandatoryControl(Control), controlStatus(S, Control, conflict).
action(S, review_consolidation(Other, Capability)) :- redundancy(S, redundant_with(Other, Capability)).

% ---------- Redundancy ----------

redundancy(S, redundant_with(Other, Capability)) :- duplicateCapability(S, Other, Capability).
redundancy(S, redundant_with(Other, Capability)) :- duplicateCapability(Other, S, Capability).

% ---------- Reporting ----------

controlSnapshot(S, Control, Status) :- mandatoryControl(Control), controlStatus(S, Control, Status).

hasFinding(S, Severity) :- once(finding(S, Severity, _)).

overallStatus(S, red) :- hasFinding(S, high).
overallStatus(S, orange) :-
    \+ hasFinding(S, high),
    once((
        hasFinding(S, medium)
    ;   hasFinding(S, low)
    )).
overallStatus(S, green) :- system(S), \+ hasFinding(S, high),
    \+ hasFinding(S, medium),
    \+ hasFinding(S, low).
