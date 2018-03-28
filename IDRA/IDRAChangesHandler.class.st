Class {
	#name : #IDRAChangesHandler,
	#superclass : #Object,
	#instVars : [
		'observers',
		'listeningForChanges',
		'connectedSockets',
		'listeningProcess',
		'writtenBytes',
		'serializer'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'IDRA-ChangesHandler'
}

{ #category : #'instance creation' }
IDRAChangesHandler class >> getInstance [
	^instance.
]

{ #category : #'instance creation' }
IDRAChangesHandler class >> newChangesListenerOnPort: aPort [
	instance := self new.
	instance listeningProcess: [ instance listenForChangesOnPort: aPort ] fork.
	^ instance
]

{ #category : #'instance creation' }
IDRAChangesHandler class >> newChangesListenerOnPort: aPort url: anUrl [
	instance := self new.
	instance startAsServerOnPort: aPort.
	IDRAMonitor isRunning
		ifTrue: [ (IDRAMonitor getInstance
				serializeOnSocketStreamMessage:
					{'changesListenerOnport'.
					aPort . anUrl}) ifFalse:[
						 ] ].
	^ instance
]

{ #category : #'instance creation' }
IDRAChangesHandler class >> newChangesSender [
	instance := self new.
	^instance.
]

{ #category : #notifying }
IDRAChangesHandler >> addObserver: anObserver [
	observers add: anObserver.
]

{ #category : #communication }
IDRAChangesHandler >> connectChangesSocketToAddress: anAddress OnPort: aPort [
	|changesSocket|
	changesSocket := nil.
	[ changesSocket isNil or: [ changesSocket isConnected == false] ] whileTrue: [ 
		changesSocket := SocketStream openConnectionToHost: anAddress port: aPort.
		changesSocket binary].
	connectedSockets add: changesSocket.
	listeningForChanges := false.
	
]

{ #category : #communication }
IDRAChangesHandler >> connectChangesSocketToUrl: aURL OnPort: aPort [
	connectedSockets add: {aURL . aPort}.
	listeningForChanges := false.
	
]

{ #category : #serialization }
IDRAChangesHandler >> fuelAccept: aGeneralMapper [
    aGeneralMapper visitSubstitution: self by: nil
]

{ #category : #initialization }
IDRAChangesHandler >> initialize [
	observers := OrderedCollection new.
	connectedSockets := OrderedCollection new.
	writtenBytes := 0.
	serializer := FLSerializer new.
	listeningForChanges := false.
	serializer
		addPostMaterializationAction: [ :materializedEntries | 
			EpLogBrowserOperationFactory new
				trigger:
					[ materializedEntries root first do: [ :each | each content accept: EpApplyVisitor new ] ]
				with: (EpRedo forAll: (EpMonitor current log referencesToAll: materializedEntries root first)) ]
]

{ #category : #communication }
IDRAChangesHandler >> listenForChangesOnPort: aPort [
	| interactionSocket connectionSocket|
"Prepare socket for handling client connection requests"
connectionSocket := Socket newTCP.
connectionSocket listenOn: aPort backlogSize: 10.
"Build a new socket for interaction with a client which connection request is accepted"
interactionSocket := connectionSocket waitForAcceptFor: 60 ifTimedOut: [ ^ self listenForChangesOnPort: aPort ].

listeningForChanges := true.
self interactWithSocket: interactionSocket executing: [:materialization | IDRAChangesHandler getInstance notifyObserversWithRestartDetails: (materialization second)].
"[ interactionSocket isConnected ] whileTrue: [ 
interactionSocket waitForData.
receivedData := OrderedCollection  new.
position := 1.
[ interactionSocket dataAvailable ] whileTrue: [ 
	(interactionSocket receiveData asByteArray) appendTo: receivedData.
	50 milliSeconds  wait ].
materialization := FLMaterializer materializeFromByteArray: (receivedData asByteArray ).
self notifyObserversWithRestartDetails: (materialization second).
]"
]

{ #category : #serialization }
IDRAChangesHandler >> listeningProcess: aProcess [
	listeningProcess := aProcess.
]

{ #category : #notifying }
IDRAChangesHandler >> notifyObservers [
	observers do: [ :each |  each signalCodeChanged ].
]

{ #category : #notifying }
IDRAChangesHandler >> notifyObserversWithRestartDetails: details [
	observers do: [ :each |  each signalCodeChangedWithRestartDetails: details ].
]

{ #category : #serialization }
IDRAChangesHandler >> refreshSocketStatus [
	connectedSockets := connectedSockets select: [ :socket | socket isConnected = true ].
]

{ #category : #accessing }
IDRAChangesHandler >> resetWritten [
	writtenBytes := 0.
]

{ #category : #serialization }
IDRAChangesHandler >> serializeAnObject: object toServer: aServer [
	self serializeOnServerURL: (aServer first) port: (aServer second) streamObject: object.
]

{ #category : #serialization }
IDRAChangesHandler >> serializeChanges [
	| entries  restartingInformation |
	listeningForChanges
		ifTrue: [ 1 inform: 'Cannot serialize in listening mode' ]
		ifFalse: [ entries := EpMonitor current log entries
				select: [ :entry | entry content isCodeChange ].
			restartingInformation := {IDRAManager getInstance restartFromMethodSelector.
			IDRAManager  getInstance restartSenderSelector}.
			connectedSockets
				do: [ :each | 
					self serializeAnObject: { entries . restartingInformation  } toServer:  each.].
			EpMonitor current log store resetWithNextStoreName ]
]

{ #category : #serialization }
IDRAChangesHandler >> serializeOnServerURL: serverURL port: serverPort streamObject: anObject [
	|sentStream|
	[sentStream := ByteArray streamContents: [ :s | serializer serialize: anObject on: s ].
	ZnClient new
   post: (serverURL , ':' , serverPort asString)  contents: sentStream.] fork.
]

{ #category : #serialization }
IDRAChangesHandler >> serializeOnSocketStreamObject: anObject [
	|sentStream|
	[sentStream := ByteArray streamContents: [ :s | serializer serialize: anObject on: s ].
	ZnClient new
   post: (serverURL , ':' , serverPort asString)  contents: sentStream.] fork.
]

{ #category : #serialization }
IDRAChangesHandler >> startAsServerOnPort: aPort [
	listeningForChanges := true.
	((ZnServer defaultOn: aPort)
		logToTranscript;
		start) onRequestRespond: [ :request |
			FLMaterializer materializeFromByteArray: request entity bytes asByteArray. 
      ZnResponse ok. ].
]

{ #category : #serialization }
IDRAChangesHandler >> stop [
	super stop.
	ZnServer default stop.
]

{ #category : #serialization }
IDRAChangesHandler >> stopListening [
	(listeningProcess isNotNil and: [ (listeningProcess isTerminated) = false  ]) ifTrue: [ 
		listeningProcess terminate ].
]

{ #category : #serialization }
IDRAChangesHandler >> syncWord [
	^ #(1 1 1 1 0 0 0 0) asByteArray 
]

{ #category : #'as yet unclassified' }
IDRAChangesHandler >> writtenBytes [
	^writtenBytes
]
