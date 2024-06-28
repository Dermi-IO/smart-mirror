import creds from '@/../../config/credentials.json';
import { WeatherResponse } from '../types/weather';

export const fetchWeather = async (  ): Promise<WeatherResponse | null> => {
    const openWeatherKey = creds.openweathermapApiKey;

    try{
        const result = await fetch(
            `https://api.openweathermap.org/data/2.5/weather?lat=35.0458&lon=-85.3094&appid=${openWeatherKey}&units=imperial`
            );

        if(result.ok){
            const weatherObj = result.json();
            return weatherObj;
        } else {
            console.log("Error fetching weather data");
            return null;
    }}catch(e){
        console.log(e);
        return null;
    }
  };