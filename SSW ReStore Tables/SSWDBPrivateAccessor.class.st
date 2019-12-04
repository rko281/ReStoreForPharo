"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBPrivateAccessor,
	#superclass : #SSWAccessor,
	#category : #'SSW ReStore Tables'
}

{ #category : #initializing }
SSWDBPrivateAccessor >> access: aSymbol in: aClass [

	"Do nothing - the receiver is hard-wired to access a private aspect of an object"
	
	^self 
]

{ #category : #testing }
SSWDBPrivateAccessor >> accesses: aSymbol [

	"Check against the specialSymbol"
	
	^aSymbol == self specialSymbol
]

{ #category : #constants }
SSWDBPrivateAccessor >> name [

	"Use the specialSymbol for this"

	^self specialSymbol
]

{ #category : #constants }
SSWDBPrivateAccessor >> nameInDB [

	"Return the name of the receiver as used for the basis of its (field) name in the database.
	Default - the specialSymbol (same as name).
	Classes with other requirements may override"

	^self specialSymbol
]

{ #category : #constants }
SSWDBPrivateAccessor >> specialSymbol [

	"Return a 'special' symbol denoting the private aspect 'accessed' by the receiver.
	This will usually be prefixed with an underscore to avoid confusion with inst vars"

	^self subclassResponsibility
]
