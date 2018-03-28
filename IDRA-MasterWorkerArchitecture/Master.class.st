Class {
	#name : #Master,
	#superclass : #Object,
	#instVars : [
		'workersSockets',
		'lastPosition'
	],
	#category : #'IDRA-MasterWorkerArchitecture'
}

{ #category : #'as yet unclassified' }
Master class >> withWorkerURLS: urls ports: ports [
	| instance |
	instance := self new.
	instance initializeWithURLS: urls ports: ports.
	^instance.
]

{ #category : #'as yet unclassified' }
Master >> connectToWorkerURL: aUrl port: aPort [
	| socket |
	socket := SocketStream openConnectionToHostNamed: aUrl  port: aPort.
	socket binary.
	workersSockets add: socket.
	[ self listenForDataFromWorkerWithSocket: socket ] fork.
]

{ #category : #'as yet unclassified' }
Master >> dataReceived: someData [
	self subclassResponsibility.
]

{ #category : #initialization }
Master >> initialize [
	lastPosition := 0.
	workersSockets := OrderedCollection new.
]

{ #category : #initialization }
Master >> initializeWithURLS: urls ports: ports [
	self initialize.
	1 to: (urls size) do: [ :i |
		self connectToWorkerURL: (urls at:i) port: (ports at: i).
		 ]
]

{ #category : #'as yet unclassified' }
Master >> listenForDataFromWorkerWithSocket: aSocket [

| receivedData materialization |
[aSocket isConnected] whileTrue: [
	receivedData := OrderedCollection  new.
	[ aSocket isDataAvailable ] whileTrue: [ 
		(aSocket nextAllInBuffer asByteArray) appendTo: receivedData.
		(aSocket isDataAvailable) ifFalse: [ (50 milliSeconds ) wait ]  ].
	(receivedData size > 0) ifTrue: [ 
	materialization := FLMaterializer materializeFromByteArray: (receivedData asByteArray ).
		self dataReceived: materialization] 
	ifFalse: [
		(100 milliSeconds wait)]] 
]

{ #category : #'as yet unclassified' }
Master >> selectWorker [
	| numberOfWorkers nextPosition position |
	numberOfWorkers := workersSockets size.
	position  := ((lastPosition + 1) % (numberOfWorkers +1)).
	(position = 0) ifTrue: [ 
		position := 1].
	lastPosition := position.
	^ workersSockets at: lastPosition.
]

{ #category : #'as yet unclassified' }
Master >> sendCommand: aCommand parameter: aParameter [
	| serializer resultString writeStream sentStream |
	serializer := FLSerializer newDefault.
	
	"resultString := ByteArray new: 1000000000.
	writeStream := resultString writeStream.
	writeStream binary."
	serializer serialize: {aCommand . aParameter} on: (self selectWorker ).
	"sentStream := ByteArray new: writeStream position.
	(1 to: (writeStream position)) do: [ 
		:i | sentStream at: i put: (resultString at: i) ]."
	" use the sender context, generally the current context is not interesting"
	"1 inform: 'Serialized a command'."
]
