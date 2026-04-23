:-['facts.pl'].

% ---------- Main query ----------

report(S, OverallStatus, Controls, Findings, Actions) :-
    system(S),
    sorted(control(Control, Status), controlStatus(S, Control, Status), Controls),
    sorted(finding(Severity, Code), finding(S, Severity, Code), Findings),
    overallStatus(Findings, OverallStatus),
    sorted(Action, action(S, Action), Actions).

% ---------- Helpers ----------

sorted(Template, Goal, Sorted) :- findall(Template, Goal, Results), sort(Results, Sorted).

usesPii(S) :- usesData(S, DataId), dataClass(DataId, pii).

% ---------- Controls ----------

controlStatus(S, owner_assigned, pass) :- owner(S, _).
controlStatus(S, owner_assigned, fail) :- system(S), \+ owner(S, _).

controlStatus(S, in_inventory, pass) :- inventory(S).
controlStatus(S, in_inventory, fail) :- system(S), \+ inventory(S).

controlStatus(S, approved, pass) :- approved(S).
controlStatus(S, approved, fail) :- system(S), \+ approved(S).

controlStatus(S, pii_guardrail, not_applicable) :- system(S), \+ usesPii(S).
controlStatus(S, pii_guardrail, pass) :- usesPii(S), guardrail(S, piiFiltering).
controlStatus(S, pii_guardrail, fail) :- usesPii(S), \+ guardrail(S, piiFiltering).

% ---------- Overlap ----------

overlap(S1, S2, Capability) :-
    system(S1), system(S2), S1 @< S2,
    capability(S1, Capability),
    capability(S2, Capability).
overlap(S, overlaps(Other, Capability)) :- overlap(S, Other, Capability).
overlap(S, overlaps(Other, Capability)) :-overlap(Other, S, Capability).

% ---------- Findings ----------

finding(S, high, pii_without_guardrail) :- controlStatus(S, pii_guardrail, fail).

finding(S, medium, no_owner) :- controlStatus(S, owner_assigned, fail).
finding(S, medium, not_in_inventory) :- controlStatus(S, in_inventory, fail).
finding(S, medium, not_approved) :- controlStatus(S, approved, fail).

finding(S, low, overlaps(Other, Capability)) :-
    overlap(S, overlaps(Other, Capability)).

% ---------- Actions ----------

action(S, add_pii_guardrail) :- controlStatus(S, pii_guardrail, fail).
action(S, assign_owner) :- controlStatus(S, owner_assigned, fail).
action(S, register_in_inventory) :- controlStatus(S, in_inventory, fail).
action(S, submit_for_approval) :- controlStatus(S, approved, fail).
action(S, review_consolidation) :- finding(S, low, overlaps(_, _)).

% ---------- Overall status ----------

overallStatus(Findings, red) :- member(finding(high, _), Findings).
overallStatus(Findings, orange) :- \+ member(finding(high, _), Findings), Findings \= [].
overallStatus([], green).
