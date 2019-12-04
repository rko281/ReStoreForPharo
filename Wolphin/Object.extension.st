Extension { #name : #Object }

{ #category : #'*Wolphin' }
Object >> asValue [

	^self asValueHolder 
]

{ #category : #'*Wolphin' }
Object >> beFinalizable [
]

{ #category : #'*Wolphin' }
Object >> beUnfinalizable [
]

{ #category : #'*Wolphin' }
Object >> debugPrintString [

	^self printString
]

{ #category : #'*Wolphin' }
Object >> displayOn: aStream [

	self printOn: aStream
]

{ #category : #'*Wolphin' }
Object >> getEvents [

	^nil
]

{ #category : #'*Wolphin' }
Object >> setEvents: anObject [
]
