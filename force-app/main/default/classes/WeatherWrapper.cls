/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : WeatherWrapper
 * Author          : <YourName>
 * Created Date    : Jun 13, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Jun 13, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class WeatherWrapper {

	
	public class  CurrentWeather {
		public Decimal temperature;
		public Decimal windspeed;
		public Integer winddirection;
	}
	public class currentWeatherUnits{
		public String windspeed;
	}
	public Decimal latitude;
	public Decimal longitude;
	public CurrentWeather current_weather;
    public currentWeatherUnits current_weather_units;
}