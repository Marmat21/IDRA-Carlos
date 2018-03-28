Class {
	#name : #ControlledTestRunner,
	#superclass : #TestRunner,
	#category : #'IDRA-TestRunner'
}

{ #category : #'as yet unclassified' }
ControlledTestRunner >> runSuiteDebugging: aTestSuite [
	| res tr |
	self executeSuite: aTestSuite as: [ :aSuite :aResult | res := aSuite debugCollecting] .
	tr := result.
	res do: [ :r | r failures do: [ :f | tr addFailure: f ]. r passed do: [ :p | tr addPass: p ] ].
	result := tr.
	self updateResults
]

{ #category : #'as yet unclassified' }
ControlledTestRunner >> runTestSuitesDebugging: testSuites [
	| te |
	self resetResult.
	
	te := CurrentExecutionEnvironment
		runTestsBy: [ testSuites
				do: [ :testSuite | self runSuiteDebugging: testSuite ]
				displayingProgress: 'Running Tests' ].
	self saveResultInHistory.
]
