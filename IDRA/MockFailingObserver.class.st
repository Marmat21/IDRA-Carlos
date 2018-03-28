Class {
	#name : #MockFailingObserver,
	#superclass : #Observer,
	#category : #'IDRA-Generator'
}

{ #category : #'as yet unclassified' }
MockFailingObserver >> activateBug [

	self doBug
]

{ #category : #'as yet unclassified' }
MockFailingObserver >> basicNotifyWith: aValue [

	self activateBug
]

{ #category : #'as yet unclassified' }
MockFailingObserver >> doBug [

	self raiseUnhandledException
]

{ #category : #'as yet unclassified' }
MockFailingObserver >> raiseUnhandledException [

	Error signal
]
