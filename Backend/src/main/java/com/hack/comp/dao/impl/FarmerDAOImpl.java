package com.hack.comp.dao.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;

import org.joda.time.DateTime;
import org.springframework.stereotype.Service;

import com.hack.comp.connection.Connections;
import com.hack.comp.dao.schema.FarmerDAO;
import com.hack.comp.model.farmer.FarmerInsert;
import com.hack.comp.model.farmer.FarmerLoginModel;
import com.hack.comp.model.farmer.FarmerPurchaseHistoryModel;

@Service
public class FarmerDAOImpl implements FarmerDAO
{

	private final static String month[] = {
			"January", 
			"February", 
			"March", 
			"April", 
			"May", 
			"June", 
			"July", 
			"August", 
			"September", 
			"October", 
			"November",
			"December" 
		  };
	
	@Override
	public FarmerLoginModel validateFarmer(String username, String password) throws SQLException, ClassNotFoundException 
	{
		 Connection c = Connections.setConnection();
	        PreparedStatement stmt = c.prepareStatement( "SELECT\n"
	        		+ "farmer.farmer_info.id,\n"
	        		+ "farmer.farmer_info.farmer_name,\n"
	        		+ "farmer.farmer_info.farmer_contact_number, \n"
	        		+ "farmer.farmer_info.survey_id,\n"
	        		+ "farmer.farmer_location.state,\n"
	        		+ "farmer.farmer_location.city,\n"
	        		+ "farmer.farmer_location.area,\n"
	        		+ "farmer.farmer_location.street,\n"
	        		+ "farmer.farmer_location.latitude,\n"
	        		+ "farmer.farmer_location.longitude\n"
	        		+ "FROM farmer.farmer_info\n"
	        		+ "JOIN farmer.farmer_location\n"
	        		+ "ON farmer.farmer_location.farmer_id=farmer.farmer_info.id\n"
	        		+ "WHERE farmer.farmer_info.id IN (\n"
	        		+ "	SELECT farmer.farmer_login.farmer_id FROM farmer.farmer_login\n"
	        		+ "	WHERE farmer.farmer_login.username=? \n"
	        		+ "	AND farmer.farmer_login.password=?\n"
	        		+ "	AND farmer.farmer_login.\"deleteIndex\" = FALSE);" );
	        stmt.setString( 1, username );
	        stmt.setString( 2, password );
	        ResultSet rs = stmt.executeQuery();
	        FarmerLoginModel flm=new FarmerLoginModel();
	        if (rs.next())
	        {
	            flm.setId(rs.getLong("id"));
	            flm.setFarmerName(rs.getString("farmer_name"));
	            flm.setFarmerContact(rs.getString("farmer_contact_number"));
	            flm.setSurveyId(rs.getString("survey_id"));
	            flm.setState(rs.getString("state"));
	            flm.setCity(rs.getString("city"));
	            flm.setArea(rs.getString("area"));
	            flm.setStreet(rs.getString("street"));
	            flm.setLatitude(rs.getString("latitude"));
	            flm.setLongitude(rs.getString("longitude"));
	            flm.setCheck(true);
	        }
	        else
	        {
	        	 flm.setCheck(false);
	        }
	     rs.close();
	     stmt.close();
	     c.close();
		return flm;
	}

	@Override
	public Boolean addFarmer(FarmerInsert fi) throws SQLException, ClassNotFoundException
	{
		Connection c = Connections.setConnection();
        PreparedStatement stmt = c.prepareStatement( "SELECT farmer.\"fn_addFarmer\"(?,?,?,?,?,?,?,?,?,?)" );
        stmt.setString( 1, fi.getFarmerName() );
        stmt.setString( 2, fi.getFarmerContact() );
        stmt.setString( 3, fi.getSurveyId() );
        stmt.setString( 4, fi.getPassword() );
        stmt.setString( 5, fi.getLatitude() );
        stmt.setString( 6, fi.getLongitude() );
        stmt.setString( 7, fi.getStreet() );
        stmt.setString( 8, fi.getArea() );
        stmt.setString( 9, fi.getCity() );
        stmt.setString( 10, fi.getState() );
        Boolean rs = stmt.execute();
        c.commit();
        stmt.close();
        c.close();
        return rs;
	}

	@Override
	public List<FarmerPurchaseHistoryModel> selectFarmerPurchaseHistory(Long farmerId)
			throws SQLException, ClassNotFoundException {
		Connection c=Connections.setConnection();
		PreparedStatement stmt=c.prepareStatement("				SELECT\n"
				+ "					public.composter_farmer_transaction.inc_id,\n"
				+ "					public.composter_farmer_transaction.composter_compost_init_id,\n"
				+ "					public.composter_farmer_transaction.composter_id, \n"
				+ "					public.composter_farmer_transaction.farmer_id,\n"
				+ "					public.composter_farmer_transaction.farmer_name,\n"
				+ "					public.composter_farmer_transaction.farmer_contact, \n"
				+ "					public.composter_farmer_transaction.date_time,\n"
				+ "					public.composter_farmer_transaction.category,\n"
				+ "					public.composter_farmer_transaction.grade,\n"
				+ "					public.composter_farmer_transaction.price,\n"
				+ "					public.composter_farmer_transaction.compost_weight\n"
				+ "				FROM\n"
				+ "					public.composter_farmer_transaction\n"
				+ "				WHERE\n"
				+ "					public.composter_farmer_transaction.farmer_id = ?;");
		stmt.setLong(1, farmerId);
		System.out.println(stmt);
		ResultSet rs=stmt.executeQuery();
		List<FarmerPurchaseHistoryModel> cf=new ArrayList<FarmerPurchaseHistoryModel>();
		while(rs.next())
		{
			DateTime dt = new DateTime(rs.getTimestamp("date_time").getTime());
			SimpleDateFormat formatDate=new SimpleDateFormat("EEEE");
			Calendar gCal=new GregorianCalendar(dt.getYear(),dt.getMonthOfYear(),dt.getDayOfMonth(),dt.getHourOfDay(),dt.getMinuteOfHour(),dt.getSecondOfMinute());
			String dateString=formatDate.format(
					rs.getTimestamp("date_time").getTime())+
					" "+
					dt.getDayOfMonth()+
					" "+
					month[gCal.get(Calendar.MONTH)-1]+
					" "+
					dt.getYear()+
					" "+
					dt.getHourOfDay()+
					":"+
					dt.getMinuteOfHour()+
					":"+
					dt.getSecondOfMinute();
			cf.add(new FarmerPurchaseHistoryModel(
					rs.getLong("inc_id"),
					rs.getLong("composter_compost_init_id"),
					rs.getLong("composter_id"),
					rs.getLong("farmer_id"),
					rs.getString("farmer_name"),
					rs.getString("farmer_contact"),
					rs.getTimestamp("date_time"),
					dateString,
					rs.getString("category"),
					rs.getString("grade"),
					rs.getDouble("price"),
					rs.getDouble("compost_weight"),
					(rs.getDouble("price")*rs.getDouble("compost_weight"))
					));
			System.out.println("Record!");
		}
		rs.close();
		stmt.close();
		c.close();
		return cf;	
	}

}
