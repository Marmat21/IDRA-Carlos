Class {
	#name : #ConsoleObserver,
	#superclass : #Observer,
	#category : #'IDRA-Generator'
}

{ #category : #'as yet unclassified' }
ConsoleObserver >> basicNotifyWith: aValue [
	Transcript crShow: aValue
]
