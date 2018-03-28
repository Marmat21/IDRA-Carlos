Extension { #name : #BlockClosure }

{ #category : #'*IDRA' }
BlockClosure >> on: exception forkAndCopyContext: handlerAction [
	"Activate the receiver. In case of exception, fork a new process, which will handle an error.
	An original process will continue running as if receiver evaluation finished and answered nil,
	i.e., an expression like:
	
	[ self error: 'some error'] on: Error fork: [:ex |  123 ] 
	
	will always answer nil for original process, not 123.

	The context stack , starting from context which sent this message to receiver and
	up to the top of the stack will be transferred to forked process, with handlerAction on top.
	(so when the forked process will be resuming, it will enter the handlerAction)
	 "
		
	| currentLevel sender senderCopy |
	^ self on: exception do: [:ex |
		| copy onDoCtx process handler bottom thisCtx checkNull |
		
		onDoCtx := thisContext.
		thisCtx := onDoCtx home.

				"copyTheContext"
		copy := ex signalerContext  copy.
		currentLevel := copy.
		sender := currentLevel sender.
		[sender == nil ] whileFalse: [ 
			senderCopy := sender copy.
			currentLevel privSender: senderCopy.
			sender := sender sender.
			currentLevel := senderCopy.
			].

		checkNull := onDoCtx isNil.
		"find the context on stack for which this method's is sender"

		[checkNull or: [ onDoCtx sender == thisCtx]] whileFalse: [ 
			onDoCtx := onDoCtx sender.
			onDoCtx ifNil: [ 
				"Can't find our home context. seems like we're already forked
				and handling another exception in new thread. In this case, just pass it through handler."
				checkNull := true.
				"handlerAction cull: ex cull: copy" ]
		 ].
		
		checkNull ifFalse: [ 
			bottom := [ Processor terminateActive ] asContext.
			onDoCtx privSender: bottom.

			handler := [ handlerAction cull: ex cull:copy] asContext.
			handler privSender: thisContext sender.

			(Process forContext: handler priority: Processor activePriority) resume.

			"cut the stack of current process"
			thisContext privSender: thisCtx.
			nil
		]
	]

]
