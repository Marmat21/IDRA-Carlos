Class {
	#name : #TestMaster,
	#superclass : #Master,
	#instVars : [
		'testRunner'
	],
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #'as yet unclassified' }
TestMaster >> dataReceived: aTestResult [
	testRunner result: aTestResult.
	testRunner updateResults.
]

{ #category : #accessing }
TestMaster >> testRunner: aTestRunner [
	testRunner := aTestRunner.
]
