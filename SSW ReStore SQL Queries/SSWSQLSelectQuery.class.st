"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLSelectQuery,
	#superclass : #SSWSQLConditionalQuery,
	#instVars : [
		'fields',
		'fieldAliases'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #'instance creation' }
SSWSQLSelectQuery class >> new [

	^super new
		fields: SSWSQLFieldCollection new;
		yourself
]

{ #category : #'accessing - derived' }
SSWSQLSelectQuery >> actualFields [

	"If the receiver represents the selection of all fields from multiple tables, 
	then special fields must be used"

	^(self fields isAll and: [self tables size > 1])
		ifTrue: [self tables inject: (SSWSQLFieldCollection new: 16) into: [ :allFields :table | allFields addAll: table allFields; yourself]]
		ifFalse: [self fields]
]

{ #category : #converting }
SSWSQLSelectQuery >> asAggregatedQuery [

	| aggregated |

	aggregated := SSWSQLAggregatedOrderedSelectQuery new.

	1 to: self class instSize do: [ :index | aggregated instVarAt: index put: (self instVarAt: index)].

	^aggregated
]

{ #category : #'accessing - derived' }
SSWSQLSelectQuery >> field: anSSWDBField [

	"Set a single field as the result field for the receiver"

	^self fields: (SSWSQLFieldCollection with: anSSWDBField)
]

{ #category : #accessing }
SSWSQLSelectQuery >> fieldAliases [

	"fieldAliases stores an IdentityDictionary mapping SSWSQLFields to an aliased name
	assigned to that field by the receiver"

	^fieldAliases
]

{ #category : #accessing }
SSWSQLSelectQuery >> fieldAliases: anIdentityDictionary [

	"fieldAliases stores an IdentityDictionary mapping SSWSQLFields to an aliased name
	assigned to that field by the receiver"

	fieldAliases := anIdentityDictionary
]

{ #category : #'accessing - derived' }
SSWSQLSelectQuery >> fieldNamed: aString [

	"Return the field with the given name (which must be an alias if the receiver has fieldAliases)"

	^self fieldAliases isNil
		ifTrue: [self actualFields fieldNamed: aString]
		ifFalse: [self fieldWithAlias: aString]
]

{ #category : #'accessing - derived' }
SSWSQLSelectQuery >> fieldWithAlias: aString [

	"Return the field with the given name (which must be an alias if the receiver has fieldAliases)"

	self fieldAliases keysAndValuesDo: [ :field :alias | alias = aString ifTrue: [^field]].

	^nil
]

{ #category : #accessing }
SSWSQLSelectQuery >> fields [

	"fields stores the collection of SSWSQLFields read by the receiver.
	This is stored as an SSWSQLFieldCollection"
	
	^fields
]

{ #category : #accessing }
SSWSQLSelectQuery >> fields: anSSWSQLFieldCollection [

	"fields stores the collection of SSWSQLFields read by the receiver.
	This is stored as an SSWSQLFieldCollection"
	
	fields := anSSWSQLFieldCollection
]

{ #category : #testing }
SSWSQLSelectQuery >> hasOrdering [

	^false
]

{ #category : #testing }
SSWSQLSelectQuery >> isReadQuery [

	^true
]

{ #category : #operations }
SSWSQLSelectQuery >> preExecIn: anSSWReStore [

	"The receiver is about to be executed in anSSWReStore.
	Carry out pre-exec validation"

	"If querying for generalised all fields in one table, replace with the true 'all fields in table' object"
	(self tables size = 1 and: [self fields isAll]) ifTrue:
		[self fields: (SSWSQLTableAllFields forTable: self table)].

	"Ensure that the tables used are the correct 'full' versions for querying"
	self tables: 
		(self tables collect: 
			[ :queryTable|| fullTable |
			fullTable := queryTable withAllFields.
			(self fields isAllInTable and: [self fields table == queryTable]) ifTrue: [self fields table: fullTable].
			fullTable])
]

{ #category : #output }
SSWSQLSelectQuery >> writeSQLOn: aStream [

	aStream nextPutAll: 'SELECT '.

	(self tables size > 1 or: [self fields requiresAliasing])
	ifTrue: 
		[self actualFields writeAliasedSQLOn: aStream.
		aStream fieldAliases isEmpty ifFalse: [self fieldAliases: aStream fieldAliases]]
	ifFalse: 
		[self actualFields writeSQLOn: aStream.
		self fieldAliases: nil].
	
	aStream nextPutAll: ' FROM '.
	self tables writeSQLOn: aStream.

	self writeWhereClauseOn: aStream
]
