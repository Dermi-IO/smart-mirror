import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import { screen } from '@testing-library/dom';


import Page from '../src/app/page';

describe('Home page test', () => {
    it('renders the clock component', () => {
        render(<Page />);
        
        const clockTile = screen.getByTestId('clock-tile');

        expect(clockTile).toBeInTheDocument();
    })
})