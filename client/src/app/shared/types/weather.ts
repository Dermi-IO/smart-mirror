export interface WeatherResponse {
    weather: {
        main: string,
        description: string
        icon: string
    }[],
    main: {
        temp: number
        feels_like: number
        temp_min: number
        temp_max: number
        pressure: number
        humidity: number
    },
    visibility: number,
    wind: {
        speed: number,
        deg: number,
        gust: number
    },
    rain: {
        "1h": number
    },
    clouds: {
        all: number
    },
}