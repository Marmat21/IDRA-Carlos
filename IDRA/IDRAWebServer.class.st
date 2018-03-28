Class {
	#name : #IDRAWebServer,
	#superclass : #IDRA,
	#instVars : [
		'serverURL',
		'serverPort',
		'toSend'
	],
	#category : #'IDRA-Debugger'
}

{ #category : #'as yet unclassified' }
IDRAWebServer class >> startAsMonitorMasterURL: anURL port: aPort [
	masterURL := anURL.
	masterPort := aPort.
]

{ #category : #'queue-handling' }
IDRAWebServer >> handleConnectionErrorWithStream: aStream [
	connectionStatus := 1.
	toSend add: aStream.
]

{ #category : #'queue-handling' }
IDRAWebServer >> initialize [
	super initialize.
	toSend := OrderedCollection new.
]

{ #category : #'queue-handling' }
IDRAWebServer >> isConnectionAlive [
	^true.
]

{ #category : #'queue-handling' }
IDRAWebServer >> openClientSocketWithServerURL: anUrl port: aPort [
	serverURL := anUrl.
	serverPort := aPort.
]

{ #category : #'queue-handling' }
IDRAWebServer >> sendFailedStreams [
	(connectionStatus = 1) ifTrue: [ 
		toSend collect: [ :each |
		[ZnClient new post: serverURL , ':' , serverPort asString contents: each.
		toSend remove: each.] fork.].
		connectionStatus := 0.
		 ]
]

{ #category : #'queue-handling' }
IDRAWebServer >> serializeOnSocketStreamMessage: aMessage [
	| sentStream |
	[ sentStream := ByteArray
		streamContents: [ :s | messageSerializer serialize: aMessage on: s ].
	ZnClient new post: serverURL , ':' , serverPort asString contents: sentStream.
	self sendFailedStreams. ]
		on: ConnectionTimedOut
		do: [ self handleConnectionErrorWithStream: sentStream ]
]

{ #category : #'queue-handling' }
IDRAWebServer >> serializeOnSocketStreamObject: anObject [
	| sentStream |
	[ sentStream := ByteArray streamContents: [ :s | serializer serialize: anObject on: s ].
	ZnClient new post: serverURL , ':' , serverPort asString contents: sentStream.
	self sendFailedStreams. ]
		on: ConnectionTimedOut, ZnMissingHost
		do: [ 1 inform: 'error in send'.self handleConnectionErrorWithStream: sentStream. ]
]

{ #category : #'queue-handling' }
IDRAWebServer >> startAsServerOnPort: aPort [
	((ZnServer defaultOn: aPort)
		logToTranscript;
		start) onRequestRespond: [ :request |
			FLMaterializer materializeFromByteArray: request entity bytes asByteArray. 
      ZnResponse ok. ].
]

{ #category : #'queue-handling' }
IDRAWebServer >> stop [
	super stop.
	ZnServer default stop.
]
