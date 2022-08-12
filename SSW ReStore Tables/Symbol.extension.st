Extension { #name : #Symbol }

{ #category : #'*SSW ReStore Tables' }
Symbol >> asInstVarName [

	^self
]

{ #category : #'*SSW ReStore Tables' }
Symbol >> databaseFieldNameIn: anSSWDBTable [

	"Return the corresponding field name of the receiver in anSSWDBTable"

	^(SSWDBInstVarDefinition name: self) databaseFieldNameIn: anSSWDBTable
]

{ #category : #'*SSW ReStore Tables' }
Symbol >> previouslyNamed: aSymbol [

	"Return an object representing the instance variable with the receiver's name, which was previously named aSymbol"

	^(SSWDBRenamedInstVar name: self)
		previousName: aSymbol;
		yourself
]

{ #category : #'*SSW ReStore Tables' }
Symbol >> withDatabaseName: aString [

	"Return an object representing the instance variable with the receiver's name, which is to be mapped to a database field with the name aString"

	^(SSWDBInstVarWithFieldName name: self) 
		fieldName: aString;
		yourself
]
