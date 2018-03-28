Class {
	#name : #TestWorker,
	#superclass : #Worker,
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #actions }
TestWorker >> runTestSuites: testSuites [

	| testRunner results res |
	testRunner:= ControlledTestRunner new.
	testSuites do: [ :aSuite |testRunner selectTests: aSuite tests].
	testRunner open.
	res := testRunner runTestSuitesDebugging:  testSuites.
	results := testRunner result.
	self sendToMaster: results.	

]

{ #category : #'as yet unclassified' }
TestWorker >> scheduleCommand: aCommand parameters: aParameter [
(aCommand = 'runTestSuites') ifTrue: [ 
	self runTestSuites: aParameter  ].
]
