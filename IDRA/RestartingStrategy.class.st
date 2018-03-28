Class {
	#name : #RestartingStrategy,
	#superclass : #Object,
	#category : #'IDRA-RestartingStrategies'
}

{ #category : #'as yet unclassified' }
RestartingStrategy class >> processError: anError inContext: aContext [
	^{ anError . aContext}
]

{ #category : #'as yet unclassified' }
RestartingStrategy class >> restartWithParameters: someParameters [
"to be called with a tuple {proceeding,errorTuple,debuggerProcess}"
	^self
]
