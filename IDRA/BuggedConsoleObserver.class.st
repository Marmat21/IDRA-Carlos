Class {
	#name : #BuggedConsoleObserver,
	#superclass : #Observer,
	#category : #'IDRA-Generator'
}

{ #category : #'as yet unclassified' }
BuggedConsoleObserver >> activateBug [

	self doBug
]

{ #category : #'as yet unclassified' }
BuggedConsoleObserver >> basicNotifyWith: aValue [
	aValue < 900 ifTrue:[
		Transcript crShow: aValue
	] ifFalse: [ 
		self activateBug
	 ]
]

{ #category : #'as yet unclassified' }
BuggedConsoleObserver >> doBug [

	self raiseUnhandledException
]

{ #category : #'as yet unclassified' }
BuggedConsoleObserver >> raiseUnhandledException [

	Error signal
]
