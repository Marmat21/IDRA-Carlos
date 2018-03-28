Extension { #name : #TestRunner }

{ #category : #'*IDRA' }
TestRunner >> selectTests: someTests [
	classesSelected := someTests collect: [:t | t class].
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]
