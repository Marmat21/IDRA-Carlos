Extension { #name : #TestResult }

{ #category : #'*IDRA' }
TestResult >> cleanStackForRemote: aStack [
	| context newStack |
	context := aStack findContextSuchThat: [ :ctx | ctx methodSelector = 'performTest' ].
	newStack := aStack cut: (context sender).
	^newStack
]

{ #category : #'*IDRA' }
TestResult >> runCaseForDebug: aTestCase [
	[
	aTestCase announce: TestCaseStarted withResult: self.
	aTestCase runCaseManaged.
	aTestCase announce: TestCaseEnded  withResult: self.
	self addPass: aTestCase]
		on: self class failure , self class skip, self class warning, self class error
		do: [:ex | 
			(IDRAMonitor getInstance started) ifTrue: [
				ex sunitAnnounce: aTestCase toResult: self.
				IDRAMonitor getInstance handleError: ex inContext: (self cleanStackForRemote: (ex signalerContext copyStack))] ifFalse: [  
			ex sunitAnnounce: aTestCase toResult: self. ex pass]]
]
