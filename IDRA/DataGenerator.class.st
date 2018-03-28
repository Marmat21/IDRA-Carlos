Class {
	#name : #DataGenerator,
	#superclass : #Object,
	#instVars : [
		'observers',
		'isRunning',
		'max',
		'ms'
	],
	#category : #'IDRA-Generator'
}

{ #category : #initialization }
DataGenerator >> initialize [
"Initialize the producer"
	observers  := Set new.
	isRunning  := false.
	max := 1000.
	ms := 20.
]

{ #category : #'as yet unclassified' }
DataGenerator >> notifyObservers: aValue [
	observers do: [ :each | each notifyWith: aValue]
]

{ #category : #initialization }
DataGenerator >> registerNewObserver: anObserver [
	"adds a new observer to the list"
	observers add: anObserver .
]

{ #category : #'as yet unclassified' }
DataGenerator >> start [
"starts the generator"
	| random |
	isRunning ifFalse: [ 
		random := Random new.
		isRunning  := true.
		[[isRunning = true] whileTrue: [ 
			[self notifyObservers: (random nextInt: max).] fork.
			ms milliSeconds wait.
		 ]] fork.
	]
]

{ #category : #'as yet unclassified' }
DataGenerator >> startWithTimeout: everyMs [
"starts the generator with a selected timeout"
	ms := everyMs.
	self start.
]

{ #category : #initialization }
DataGenerator >> stop [
	isRunning  := false.
]
