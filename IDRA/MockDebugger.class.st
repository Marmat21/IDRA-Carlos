Class {
	#name : #MockDebugger,
	#superclass : #Object,
	#category : #'IDRA-Test'
}

{ #category : #accessing }
MockDebugger >> capturedContext [
	^ capturedContext
]

{ #category : #accessing }
MockDebugger >> capturedError [
	^ capturedError
]

{ #category : #'error handling' }
MockDebugger >> capturedProcess [
	^capturedProcess 
]

{ #category : #'error handling' }
MockDebugger >> handleError: anError inContext: aContext [ 
	
	capturedError := anError.
	capturedContext := aContext.
	capturedProcess := Processor activeProcess .
]
