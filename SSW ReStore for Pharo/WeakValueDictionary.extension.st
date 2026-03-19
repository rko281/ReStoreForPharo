Extension { #name : 'WeakValueDictionary' }

{ #category : '*SSW ReStore for Pharo' }
WeakValueDictionary >> dbApproxSize [
	"db-prefixed copy of Porpoise implementation to avoid creating dependency.
	
	Use the raw tally--this may be an overestimate if some values have been
	garbage collected, but it is more important to be fast."

	^ tally
]
