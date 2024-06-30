import { YoutubePopover } from "./components/popovers/Youtube/youtube";
import Clock from "./components/tiles/Clock/clock";
import Weather from "./components/tiles/Weather/weather";
import { getMirrorConfig } from "./shared/utils/get-config";

export default function Home() {
  const mirrorConfig = getMirrorConfig();

  const { tilesX, tilesY, showGrid, mirrorPadding} = mirrorConfig;

  const borderClasses = showGrid ? "border border-gray-400 " : "";

  const gridItems = Array.from({ length: tilesX * tilesY }, (_, index) => (
    <div key={index} className={`grid-item overflow-hidden ${borderClasses}${index in [0] ? 'col-span-2' : ''}`}>
      {index === 0 && <Clock />} {/* Display the clock only in the first grid item */}
      {index === 3 && <Weather />}
    </div>
  ));

  return (
    <main
      className={`grid w-full h-screen p-${mirrorPadding ?? 24}`}
      style={{
        gridTemplateColumns: `repeat(${tilesX}, 1fr)`,
        gridTemplateRows: `repeat(${tilesY}, 1fr)`,
      }}
    >
      { gridItems }
      <YoutubePopover />
  </main>
  );
}
