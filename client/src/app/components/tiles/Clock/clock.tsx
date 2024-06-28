'use client'
import React from "react"
import './clock-animation.css'


const Clock: React.FC = () => {
  const [date, setDate] = React.useState(new Date())

  React.useEffect(() => {
    const timer = setInterval(() => setDate(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  return (
    <div className="clock-container relative w-full h-full">
      <div id="clock" className="moving-clock absolute">
        <div className="text-white text-4xl font-bold relative" data-testid="clock-tile">
            {date.toLocaleTimeString()}
        </div>
      </div>
    </div>
  )
}

export default Clock;