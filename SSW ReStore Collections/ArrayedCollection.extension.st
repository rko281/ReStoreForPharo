Extension { #name : #ArrayedCollection }

{ #category : #'*SSW ReStore Collections' }
ArrayedCollection >> _dbAdd: anObject suggestedIndex: anInteger [

	"Translate to at:put:"

	^self at: anInteger put: anObject


]

{ #category : #'*SSW ReStore Collections' }
ArrayedCollection >> staticCollectionSpecClass [ 

	^SSWDBArrayedStaticCollectionSpec


]
