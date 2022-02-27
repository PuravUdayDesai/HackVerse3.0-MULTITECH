package com.hack.comp.aspect;

import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailAspect {
	public static void sendEmailWithoutAttachment(String toEmailid, String mailToType, String subject,
			String bodyContent, String bodyContentType) throws MessagingException {
		String host = "smtp.gmail.com";
		final String user = "<EMAIL-ID>";
		final String password = "<PASSWORD>";
		Properties props = new Properties();
		props.put("mail.smtp.host", host); 
		props.put("mail.smtp.port", "25"); 
		props.put("mail.debug", "true"); 
		props.put("mail.smtp.auth", "true"); 
		props.put("mail.smtp.starttls.enable","true"); 
		props.put("mail.smtp.EnableSSL.enable","true");

		props.setProperty("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");   
		props.setProperty("mail.smtp.socketFactory.fallback", "false");   
		props.setProperty("mail.smtp.port", "465");   
		props.setProperty("mail.smtp.socketFactory.port", "465");
		Session session = Session.getDefaultInstance(props, new javax.mail.Authenticator() {
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(user, password);
			}
		});

		MimeMessage message = new MimeMessage(session);

		message.setFrom(new InternetAddress(user));
		message.addRecipient(
				mailToType.equalsIgnoreCase("TO") ? Message.RecipientType.TO
						: mailToType.equalsIgnoreCase("BCC") ? Message.RecipientType.BCC : Message.RecipientType.CC,
				new InternetAddress(toEmailid));
		message.setSubject(subject);
		message.setContent(bodyContent, bodyContentType);
		Transport.send(message);
	}
}
