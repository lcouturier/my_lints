typedef Record = (String, String);

// LINT: Avoid declaring extensions on record types. Try declaring a class instead.
extension Extension on (String, String) {}

// LINT: Avoid declaring extensions on record types. Try declaring a class instead.
extension RecordX on Record {}
