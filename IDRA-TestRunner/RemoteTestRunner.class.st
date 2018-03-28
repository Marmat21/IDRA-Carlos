Class {
	#name : #RemoteTestRunner,
	#superclass : #TestRunner,
	#instVars : [
		'master'
	],
	#category : #'IDRA-TestRunner'
}

{ #category : #'as yet unclassified' }
RemoteTestRunner class >> openWithMaster: aMaster [
	|instance|
	instance := self new.
	instance master: aMaster.
	aMaster testRunner: instance.
	^(instance open).
]

{ #category : #accessing }
RemoteTestRunner >> buttons [
	^ #(( 'Run Selected' #runAll 'Run all selected tests' #hasRunnable )
		('Run Online Debugging' #runAllDebugging 'Run all selected tests debugging them' #hasRunnable))
		"( 'Run Profiled' #runProfiled 'Run tests and profile' #hasRunnable )
		( 'Run Coverage' #runCoverage 'Run test and check code coverage' #hasRunnable )
		( 'Run Failures' #runFailures 'Run all failures' #hasFailures )
		( 'Run Errors' #runErrors 'Run all errors' #hasErrors )
		( 'File out results' #fileOutResults 'File out test results' #hasFailuresOrErrors))"
]

{ #category : #accessing }
RemoteTestRunner >> label [
	^ 'Remote Test Runner'
]

{ #category : #accessing }
RemoteTestRunner >> master: aMaster [
	master := aMaster
]

{ #category : #accessing }
RemoteTestRunner >> result: aResult [
	result := aResult.
]

{ #category : #accessing }
RemoteTestRunner >> runAllDebugging [
	self resetResult.
	master sendCommand: 'runTestSuites' parameter: self allSelectedTestSuites
]
