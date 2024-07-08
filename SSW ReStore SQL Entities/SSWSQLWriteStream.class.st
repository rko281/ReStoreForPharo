"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLWriteStream',
	#superclass : 'WriteStream',
	#instVars : [
		'dialect',
		'fieldAliases',
		'tableAliases',
		'parameterizedFields',
		'parameterizedValues',
		'placeholderCount'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLWriteStream class >> newIn: anSSWSQLDialect [

	^(self on: (String new: 32))
		dialect: anSSWSQLDialect;
		fieldAliases: IdentityDictionary new;
		tableAliases: IdentityDictionary new;
		parameterizedFields: OrderedCollection new;
		parameterizedValues: OrderedCollection new;
		placeholderCount: 0;
		yourself
]

{ #category : 'accessing' }
SSWSQLWriteStream >> dialect [

	"dialect stores the SSWSQLDialect of the database for which the receiver stream is writing SQL"

	^dialect
]

{ #category : 'accessing' }
SSWSQLWriteStream >> dialect: anSSWSQLDialect [

	"dialect stores the SSWSQLDialect of the database for which the receiver stream is writing SQL"

	dialect := anSSWSQLDialect
]

{ #category : 'accessing' }
SSWSQLWriteStream >> fieldAliases [

	"fieldAliases stores an IdentityDictionary mapping SSWSQLFields to an aliased name
	assigned to that field by the receiver"

	^fieldAliases
]

{ #category : 'accessing' }
SSWSQLWriteStream >> fieldAliases: anIdentityDictionary [

	"fieldAliases stores an IdentityDictionary mapping SSWSQLFields to an aliased name
	assigned to that field by the receiver"

	fieldAliases := anIdentityDictionary
]

{ #category : 'testing' }
SSWSQLWriteStream >> hasParameterizedFields [

	^self parameterizedFields isEmpty not
]

{ #category : 'accessing' }
SSWSQLWriteStream >> nextFieldAlias [

	^self dialect transformInstVarName: ('field_', (self fieldAliases size + 1) printString) asSymbol


]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPut: anObject forField: aField [

	"Always use a parameterized field if possible"

	(aField canBeParameterized and: [anObject sqlCanBeParameterized]) 
		ifTrue: [self nextPutParameterizedValue: anObject forField: aField]
		ifFalse: [anObject writeSQLOn: self]
]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPutAliasedField: anSSWSQLField [

	"Append to the receiver an aliased representation of anSSWSQLField"

	anSSWSQLField writeSQLOn: self.
	self
		nextPutAll: ' AS ';
		nextPutAll: (self fieldAliases at: anSSWSQLField ifAbsentPut: [self nextFieldAlias])
]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPutAliasedTable: anSSWSQLTable [

	"Append to the receiver an aliased representation of anSSWSQLTable"

	self nextPutAll: (self tableAliases at: anSSWSQLTable ifAbsentPut: [self nextTableAlias])
]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPutIdentifier: aString [

	self 
		nextPut: self dialect identifierQuoteOpen;
		nextPutAll: aString;
		nextPut: self dialect identifierQuoteClose
]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPutParameterPlaceholder [

	self placeholderCount: self placeholderCount + 1.
	self dialect printParameterPlaceholder: self placeholderCount on: self
]

{ #category : 'printing' }
SSWSQLWriteStream >> nextPutParameterizedValue: anObject forField: aField [

	self nextPutParameterPlaceholder.
	self parameterizedFields add: aField.
	self parameterizedValues add: anObject
]

{ #category : 'accessing' }
SSWSQLWriteStream >> nextTableAlias [

	^self dialect transformClassName: ('table', (self tableAliases size + 1) printString) asSymbol
]

{ #category : 'accessing' }
SSWSQLWriteStream >> parameterizedFields [
	^parameterizedFields
]

{ #category : 'accessing' }
SSWSQLWriteStream >> parameterizedFields: anObject [
	parameterizedFields := anObject
]

{ #category : 'accessing' }
SSWSQLWriteStream >> parameterizedValues [
	^parameterizedValues
]

{ #category : 'accessing' }
SSWSQLWriteStream >> parameterizedValues: anObject [
	parameterizedValues := anObject
]

{ #category : 'accessing' }
SSWSQLWriteStream >> placeholderCount [
	^placeholderCount
]

{ #category : 'accessing' }
SSWSQLWriteStream >> placeholderCount: anObject [
	placeholderCount := anObject
]

{ #category : 'accessing' }
SSWSQLWriteStream >> tableAliases [

	"tableAliases stores an IdentityDictionary mapping SSWSQLTables to an aliased name
	assigned to that field by the receiver"

	^tableAliases
]

{ #category : 'accessing' }
SSWSQLWriteStream >> tableAliases: anIdentityDictionary [

	"tableAliases stores an IdentityDictionary mapping SSWSQLTables to an aliased name
	assigned to that field by the receiver"

	tableAliases := anIdentityDictionary
]

{ #category : 'printing' }
SSWSQLWriteStream >> writeSQLFor: anObject [

	anObject writeSQLOn: self
]
