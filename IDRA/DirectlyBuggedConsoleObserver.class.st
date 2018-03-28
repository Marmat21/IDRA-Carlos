Class {
	#name : #DirectlyBuggedConsoleObserver,
	#superclass : #Observer,
	#instVars : [
		'limit',
		'count'
	],
	#category : #'IDRA-Generator'
}

{ #category : #'instance creation' }
DirectlyBuggedConsoleObserver class >> newWithLimit: aLimit [
	 |obj|
	obj := self new.
	obj initializeWithLimit: aLimit.
	^ obj.
]

{ #category : #'as yet unclassified' }
DirectlyBuggedConsoleObserver >> NotifyWith: aValue [
	aValue < 900 ifTrue:[
		Transcript crShow: aValue
	] ifFalse: [ 
		OnlineHandlableError signal.
	 ]
]

{ #category : #initialization }
DirectlyBuggedConsoleObserver >> initialize [
	limit := 999.
	count := 0.
]

{ #category : #initialization }
DirectlyBuggedConsoleObserver >> initializeWithLimit: aLimit [
	limit := aLimit.
]

{ #category : #'as yet unclassified' }
DirectlyBuggedConsoleObserver >> notifyWith: aValue [
	aValue < 1002 ifTrue:[
		Transcript crShow: aValue
	] ifFalse: [ 
			OnlineHandlableError signal.
		"(count < 10) ifTrue: [
			count := count + 1.]"
	 ]
]
