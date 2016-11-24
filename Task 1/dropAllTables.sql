Begin
 FOR cur_rec in (select object_name, object_type from user_objects where object_type in ('TABLE', 'VIEW'))
 LOOP 
  BEGIN 
    IF cur_rec.object_type = 'TABLE'
    THEN
      EXECUTE IMMEDIATE 'DROP '|| cur_rec.object_type ||  ' "' || cur_rec.object_name || '" CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"';
    END IF;
    EXCEPTION
     WHEN OTHERS
     THEN DBMS_OUTPUT.put_line('FAILED: DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"');
  END;
 END LOOP;
END;