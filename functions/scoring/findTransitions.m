function Transitions = findTransitions(strScores)

Transitions = zeros(size(strScores));

T = diff(strScores)~=0;
Start = logical([T, 1]);
End = logical([1, T]);

Transitions(Start) = 1;
Transitions(End) = 1;

Transitions = logical(Transitions);
