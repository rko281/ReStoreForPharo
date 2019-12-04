Class {
	#name : #DolphinSessionManager,
	#superclass : #Object,
	#instVars : [
		'startUpActions'
	],
	#classInstVars : [
		'current'
	],
	#category : #Wolphin
}

{ #category : #accessing }
DolphinSessionManager class >> current [

	^current ifNil: [ current := self new ]
]

{ #category : #'class initialization' }
DolphinSessionManager class >> initialize [ 

	Smalltalk addToStartUpList: self
]

{ #category : #accessing }
DolphinSessionManager class >> reset [

	current := nil
]

{ #category : #'system startup' }
DolphinSessionManager class >> startUp: isNewSession [

	self current onStartUp
]

{ #category : #adding }
DolphinSessionManager >> addStartUpAction: aBlock [

	startUpActions add: aBlock
]

{ #category : #initialization }
DolphinSessionManager >> initialize [

	startUpActions := OrderedCollection new
]

{ #category : #'event handling' }
DolphinSessionManager >> onStartUp [

	startUpActions do: [ :each | each value ]
]

{ #category : #announcing }
DolphinSessionManager >> when: aSymbol send: aSelector to: anObject [

	aSymbol = #sessionStarted ifTrue: [ ^self addStartUpAction: [ anObject perform: aSelector ] ]
]
