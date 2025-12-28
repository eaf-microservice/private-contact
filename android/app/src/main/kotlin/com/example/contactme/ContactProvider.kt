package com.eafmicroservice.pravitecontact

import android.content.Context
import android.database.Cursor
import android.provider.ContactsContract

class ContactProvider(private val context: Context) {
    fun fetchContacts(): List<Map<String, Any>> {
        val resolver = context.contentResolver
        val contacts = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(
            ContactsContract.Contacts._ID,
            ContactsContract.Contacts.DISPLAY_NAME
        )

        val cursor: Cursor? = resolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        cursor?.use { c ->
            val idIdx = c.getColumnIndex(ContactsContract.Contacts._ID)
            val nameIdx = c.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
            while (c.moveToNext()) {
                val id = c.getString(idIdx)
                val name = c.getString(nameIdx) ?: ""

                val phones = mutableListOf<String>()
                val pCursor = resolver.query(
                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                    arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
                    "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
                    arrayOf(id),
                    null
                )
                pCursor?.use { pc ->
                    val numIdx = pc.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                    while (pc.moveToNext()) {
                        phones.add(pc.getString(numIdx) ?: "")
                    }
                }

                val emails = mutableListOf<String>()
                val eCursor = resolver.query(
                    ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                    arrayOf(ContactsContract.CommonDataKinds.Email.ADDRESS),
                    "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?",
                    arrayOf(id),
                    null
                )
                eCursor?.use { ec ->
                    val emIdx = ec.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)
                    while (ec.moveToNext()) {
                        emails.add(ec.getString(emIdx) ?: "")
                    }
                }

                contacts.add(mapOf(
                    "id" to id,
                    "displayName" to name,
                    "phones" to phones,
                    "emails" to emails
                ))
            }
        }
        return contacts
    }
}
