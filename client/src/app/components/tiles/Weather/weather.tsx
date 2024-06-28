'use client'

import Image from 'next/image';
import { WeatherResponse } from "@/app/shared/types/weather";
import { fetchWeather } from "@/app/shared/utils/fetch-weather";
import React, { useEffect, useState } from "react"

const Text: React.FC = () => {
  const [weather, setWeather] = useState<WeatherResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const getWeather = async () => {
      try {
        const weatherData = await fetchWeather();
        setWeather(weatherData);
        console.log(weatherData);
      } catch (error) {
        setError("Error getting weather data");
      }
    }

    getWeather();
  }, []);

  return (
    weather ? (
      <div className="text-white text-xl font-bold">
        Weather in <span className='text-orange-700'>Chattanooga</span>
        <div>Temperature: {weather.main.temp}°C</div>
        <div>Humidity: {weather.main.humidity}%</div>
        <div className="flex items-center">
            <Image src={`https://openweathermap.org/img/wn/${weather.weather[0].icon}@2x.png`} alt='weather icon' width={60} height={60} />
            <div>{weather.weather[0].main}</div>
        </div>
      </div>
    ) : (
      <div>{error}</div>
    )
  )
}

export default Text;
