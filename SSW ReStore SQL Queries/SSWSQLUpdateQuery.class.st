"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLUpdateQuery,
	#superclass : #SSWSQLConditionalQuery,
	#instVars : [
		'fieldUpdates'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #accessing }
SSWSQLUpdateQuery >> fieldUpdates [

	"fieldUpdates stores an SSWSQLFieldCollection of SSWSQLConditions that
	define the updates to be written by the receiver"
	
	^fieldUpdates
]

{ #category : #accessing }
SSWSQLUpdateQuery >> fieldUpdates: anSSWSQLFieldCollection [ 

	"fieldUpdates stores an SSWSQLFieldCollection of SSWSQLConditions that
	define the updates to be written by the receiver"
	
	fieldUpdates := anSSWSQLFieldCollection 
]

{ #category : #evaluating }
SSWSQLUpdateQuery >> parameterisedFields [

	| parameterisedFields |

	parameterisedFields := OrderedCollection new.

	self fieldUpdates do:
		[ :fieldUpdate |
		fieldUpdate value == SSWSQLQueryParameter ifTrue: [parameterisedFields add: fieldUpdate field]].

	^parameterisedFields, super parameterisedFields
]

{ #category : #output }
SSWSQLUpdateQuery >> writeSQLOn: aStream [

	aStream nextPutAll: 'UPDATE '.
	self table writeSQLOn: aStream.
	
	aStream nextPutAll: ' SET '.
	self fieldUpdates writeSQLOn: aStream.
	
	self writeWhereClauseOn: aStream
]
