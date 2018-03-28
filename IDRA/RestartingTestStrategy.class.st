Class {
	#name : #RestartingTestStrategy,
	#superclass : #RestartingStrategy,
	#category : #'IDRA-RestartingStrategies'
}

{ #category : #initialization }
RestartingTestStrategy class >> reScheduleFromContext: aContext [
	| task |
	task := IDRA getInstance findTaskFromContext: aContext.
	IDRA worker runner schedule: task.
	
]

{ #category : #'as yet unclassified' }
RestartingTestStrategy class >> reScheduleFromTestRunContextParameters: aParameter [
	| proceeding data process context sendingContext |
	proceeding := aParameter first.
	data := aParameter second.
	process := aParameter third.
	context := data second.
	sendingContext := context findContextSuchThat: [ :ctx | (ctx methodSelector = 'runCaseForDebug') and: [ctx sender methodSelector = 'debug']].
	(sendingContext isNotNil) ifTrue: [ 
		IDRA getInstance restartFromMethodSelector: (sendingContext methodSelector).
		IDRA getInstance restartSenderSelector: (sendingContext sender methodSelector).
		DefaultStrategy restartWithParameters: aParameter.
		 ]
	
]

{ #category : #'as yet unclassified' }
RestartingTestStrategy class >> restartWithParameters: aParameter [
	| proceeding data process |
	proceeding := aParameter first.
	data := aParameter second.
	process := aParameter third.
	self reScheduleFromTestRunContextParameters: aParameter.
]
