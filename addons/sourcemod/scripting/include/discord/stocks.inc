stock int JsonObjectGetInt(Handle hElement, char[] key) {
	Handle hObject = json_object_get(hElement, key);
	if(hObject == INVALID_HANDLE) return 0;
	
	int value;
	if(json_is_integer(hObject)) {
		value = json_integer_value(hObject);
	}else if(json_is_string(hObject)) {
		char buffer[12];
		json_string_value(hObject, buffer, sizeof(buffer));
		value = StringToInt(buffer);
	}
	CloseHandle(hObject);
	return value;
}

stock bool JsonObjectGetString(Handle hElement, char[] key, char[] buffer, maxlength) {
	Handle hObject = json_object_get(hElement, key);
	if(hObject == INVALID_HANDLE) return false;
	
	if(json_is_integer(hObject)) {
		IntToString(json_integer_value(hObject), buffer, maxlength);
	}else if(json_is_string(hObject)) {
		json_string_value(hObject, buffer, maxlength);
	}else if(json_is_real(hObject)) {
		FloatToString(json_real_value(hObject), buffer, maxlength);
	}else if(json_is_true(hObject)) {
		FormatEx(buffer, maxlength, "true");
	}else if(json_is_false(hObject)) {
		FormatEx(buffer, maxlength, "false");
	}
	CloseHandle(hObject);
	return true;
}

stock bool JsonObjectGetBool(Handle hElement, char[] key, bool defaultvalue=false) {
	Handle hObject = json_object_get(hElement, key);
	if(hObject == INVALID_HANDLE) return defaultvalue;
	
	bool ObjectBool = defaultvalue;
	
	if(json_is_integer(hObject)) {
		ObjectBool = view_as<bool>(json_integer_value(hObject));
	}else if(json_is_string(hObject)) {
		char buffer[11];
		json_string_value(hObject, buffer, sizeof(buffer));
		if(StrEqual(buffer, "true", false)) {
			ObjectBool = true;
		}else if(StrEqual(buffer, "false", false)) {
			ObjectBool = false;
		}else {
			int x = StringToInt(buffer);
			ObjectBool = view_as<bool>(x);
		}
	}else if(json_is_real(hObject)) {
		ObjectBool = view_as<bool>(RoundToFloor(json_real_value(hObject)));
	}else if(json_is_true(hObject)) {
		ObjectBool = true;
	}else if(json_is_false(hObject)) {
		ObjectBool = false;
	}
	CloseHandle(hObject);
	return ObjectBool;
}

stock float JsonObjectGetFloat(Handle hJson, char[] key, float defaultValue=0.0) {
	Handle hObject = json_object_get(hJson, key);
	if(hObject == INVALID_HANDLE) return defaultValue;
	
	float value = defaultValue;
	if(json_is_integer(hObject)) {
		value = float(json_integer_value(hObject));
	}else if(json_is_real(hObject)) {
		value = json_real_value(hObject);
	}else if(json_is_string(hObject)) {
		char buffer[12];
		json_string_value(hObject, buffer, sizeof(buffer));
		value = StringToFloat(buffer);
	}
	CloseHandle(hObject);
	return value;
}
