Class {
	#name : #TaskItStrategy,
	#superclass : #RestartingStrategy,
	#category : #'IDRA-RestartingStrategies'
}

{ #category : #initialization }
TaskItStrategy class >> processError: anError inContext: aContext [
	| cuttedStack |
	cuttedStack := self cutStack: aContext second copy beforeSelector: 'doExecuteTask'.
	anError searchFrom: cuttedStack.
	^{anError . cuttedStack}.
	
]

{ #category : #initialization }
TaskItStrategy class >> reScheduleFromContext: aContext [
	| task |
	task := self findTaskFromContext: aContext.
	IDRADebugger worker runner schedule: task.
	
]

{ #category : #'as yet unclassified' }
TaskItStrategy class >> restartWithParameters: aParameter [
	| proceeding data process |
	proceeding := aParameter first.
	data := aParameter second.
	process := aParameter third.
	self reScheduleFromContext: (data second).
]
