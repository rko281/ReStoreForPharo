Extension { #name : 'Process' }

{ #category : '*SSW ReStore for Pharo' }
Process >> isExpectedToResumePromptly [

	^ self isActive or: [ self suspendingList notNil ]
]

{ #category : '*SSW ReStore for Pharo' }
Process >> isInIDECallStack [

	"Answer whether this process is currently in a call stack originating in a message send from well-known IDE classes.
	Used to adjust behaviour of SSWDBProxies depending on exection context"

	| ideClasses nonIDEClasses glmWidgetRenderer frame receiver |

	"Done by name to avoid creating a package dependency on the development environment"
	ideClasses := (#(#ProcessBrowser #GTMoldableDebugger #GTSpecPreDebugPresenter #GTInspector #GTObjectPrinter #StInspector #StDebugger) collect: [ :each | self class environment at: each ifAbsent: [nil]]) reject: [ :each | each isNil].
	nonIDEClasses := (#(#StPlayground "subclass of StInspector") collect: [ :each | self class environment at: each ifAbsent: [nil]]) reject: [ :each | each isNil].
	glmWidgetRenderer  := self class environment at: #GLMMorphicWidgetRenderer ifAbsent: [ nil ].
	
	frame := thisContext sender.
	receiver := frame receiver.

	[frame notNil] whileTrue: 
		[| receiverClass nextReceiver topShell |
		receiverClass := receiver basicClass.
		(glmWidgetRenderer notNil and: [receiverClass includesBehavior: glmWidgetRenderer])
		ifTrue: 
			[ topShell := receiver renderer ifNotNil: [ :renderer | renderer window ifNotNil: [ :win | win model ]]]
		ifFalse: 
			[ ((receiverClass includesBehavior: SpAbstractPresenter) or:[receiverClass includesBehavior: Morph]) ifTrue: [ topShell := receiver topShell ]].
		topShell ifNotNil: 
				[^(nonIDEClasses allSatisfy: [ :each | (topShell isKindOf: each) not]) and: [ideClasses anySatisfy: [ :each | topShell isKindOf: each ]]].

		((nonIDEClasses allSatisfy: [ :each | (receiverClass includesBehavior: each) not]) and: [ideClasses anySatisfy: [ :each | receiverClass includesBehavior: each ]]) ifTrue: [ ^ true ].

		[frame := frame sender.
		frame notNil and: [(nextReceiver := frame receiver) isNil or: [nextReceiver == receiver]]] whileTrue.
		receiver := nextReceiver].

	^false
]
