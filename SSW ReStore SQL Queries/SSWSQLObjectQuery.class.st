"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLObjectQuery,
	#superclass : #SSWSQLQuery,
	#instVars : [
		'object',
		'table'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #'instance creation' }
SSWSQLObjectQuery class >> forObject: aProxydObject [

	^self new
		object: aProxydObject;
		yourself
]

{ #category : #testing }
SSWSQLObjectQuery >> isWriteQuery [

	^true
]

{ #category : #accessing }
SSWSQLObjectQuery >> object [

	"object stores the proxy'd persistent object on which the receiver represents its query"
	
	^object
	
]

{ #category : #accessing }
SSWSQLObjectQuery >> object: aProxydObject [

	"object stores the proxy'd persistent object on which the receiver represents its query"
	
	object := aProxydObject
	
]

{ #category : #evaluating }
SSWSQLObjectQuery >> objectControlConditions [

	"Create and return an SSWSQLConditionCollection which constrains the receiver query
	by whatever fields are in the table's controlFields"
	
	| conditions |

	conditions := SSWSQLConditionCollection forAND.

	self table controlFields do:
		[ :controlField |
		conditions add:
			(SSWSQLCondition
				field: controlField
				equalTo: (controlField accessor valueIn: self object))].

	^conditions
]

{ #category : #evaluating }
SSWSQLObjectQuery >> objectIDCondition [

	"Create and return an SSWSQLCondition which identifies the receiver's object
	within its table"
	
	^SSWSQLCondition 
		field: self table idField
		equalTo: self object _id
]

{ #category : #accessing }
SSWSQLObjectQuery >> table [

	"table is a lazy-initialized cache for the table to which the receiver's object belongs"
	
	table == nil ifTrue: [table := object _dbTable].
	
	^table
]

{ #category : #accessing }
SSWSQLObjectQuery >> table: anSSWDBTable [

	"table is a lazy-initialized cache for the table to which the receiver's object belongs"
	
	table := anSSWDBTable
]
