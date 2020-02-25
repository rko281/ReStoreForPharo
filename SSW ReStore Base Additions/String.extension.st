Extension { #name : #String }

{ #category : #'*SSW ReStore Base Additions' }
String class >> fixedSize: anInteger [

	"For DB support: specifies a fixed-sized String of anInteger characters"

	^SSWDBFixedStringWithInfo new
		fieldSize: anInteger;
		yourself
]

{ #category : #'*SSW ReStore Base Additions' }
String class >> isPersistentBaseClass [

	^true
]

{ #category : #'*SSW ReStore Base Additions' }
String class >> maxSize: anInteger [

	"For DB support: specifies a variable-sized String with a maximum size of anInteger"

	^SSWDBVariableStringWithInfo new
		fieldSize: anInteger;
		yourself
]

{ #category : #'*SSW ReStore Base Additions' }
String >> orNilIfEmpty [

	^self isEmpty
		ifTrue: [nil]
		ifFalse: [self]
]
