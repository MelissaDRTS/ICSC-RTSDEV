public without sharing class SharingOverride 
{
	public static void UpsertRecords(List<sObject> records)
	{
		upsert records;
	}
	
	public static void deleteRecords(List<sObject> records)
	{
		delete records;
	}
}