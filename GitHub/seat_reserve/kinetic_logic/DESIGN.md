---
name: Kinetic Logic
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002113'
  on-tertiary-container: '#009668'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-code:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  container-padding-desktop: 40px
  container-padding-mobile: 16px
  gutter: 24px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style

This design system is built for high-performance software engineering environments where focus and clarity are paramount. The brand personality is **authoritative yet enabling**, striking a balance between corporate reliability and the energetic pace of a modern tech hub. 

The aesthetic follows a **Modern Corporate** direction with subtle **Minimalist** influences. It prioritizes information density without sacrificing breathing room, ensuring that developers and managers can assess seat availability and status at a glance. Visual noise is eliminated in favor of functional clarity, using purposeful color application to signal system states. The emotional response should be one of "effortless organization" and "technical precision."

## Colors

The palette is anchored by **Deep Slate (Primary)** to provide a professional, grounded foundation. **Electric Blue (Secondary)** is used for primary actions and interactive states, while **Emerald Green (Tertiary)** is reserved specifically for "Available" and "Approved" statuses to provide an immediate positive psychological cue.

- **Primary:** Navigation, headings, and deep backgrounds.
- **Secondary:** Buttons, active links, and focus states.
- **Tertiary:** Success states, seat availability, and "Approved" badges.
- **Neutrals:** Used for borders, secondary text, and subtle surface divisions.
- **Surface:** The background uses a very light cool gray to reduce eye strain during prolonged use compared to pure white.

## Typography

This design system utilizes **Hanken Grotesk** for its exceptional legibility and contemporary geometric feel. It provides the "professional yet modern" tone required for a software house environment. For technical identifiers—such as Seat IDs, IP addresses, or hardware codes—**JetBrains Mono** is used to provide a distinct visual "coding" texture that resonates with the target audience.

- **Headlines:** High weight and tight tracking for a strong typographic hierarchy.
- **Body:** Standardized at 16px for optimal reading on desktop displays.
- **Monospace Labels:** Used for status badges and ID tags to differentiate data from descriptive text.

## Layout & Spacing

The layout employs a **12-column fluid grid** for desktop, transitioning to a **4-column grid** for mobile. A strict 8px spacing scale ensures mathematical harmony across all components.

- **Desktop:** 40px outer margins with 24px gutters. Use "Max-width" containers (1280px) for centered dashboard layouts.
- **Tablet:** 24px outer margins.
- **Mobile:** 16px outer margins.
- **Alignment:** All interactive elements and card contents should follow a vertical rhythm based on the `stack` variables to maintain visual consistency.

## Elevation & Depth

Depth is communicated through **Tonal Layers** and extremely subtle **Ambient Shadows**. We avoid heavy shadows to maintain a clean, high-performance feel.

- **Level 0 (Background):** `background_default` (#F8FAFC).
- **Level 1 (Cards/Surface):** Pure white (#FFFFFF) with a 1px border (#E2E8F0).
- **Level 2 (Hover/Active):** A soft, diffused shadow (0px 4px 12px rgba(15, 23, 42, 0.05)) to indicate interactivity.
- **Level 3 (Modals/Popovers):** Higher contrast shadow (0px 12px 24px rgba(15, 23, 42, 0.1)) to pull the element forward from the workspace.

Navigation sidebars should use a distinct tonal shift (Deep Slate) rather than shadows to define their boundary.

## Shapes

The design system utilizes a **Soft (Level 1)** shape language. This ensures the UI feels modern and approachable while maintaining a structured, professional "grid-like" efficiency.

- **Standard Buttons & Inputs:** 0.25rem (4px) corner radius.
- **Cards & Containers:** 0.5rem (8px) corner radius.
- **Status Badges:** 100px (Full Pill) to differentiate them from square-ish interactive buttons.

## Components

### Status Badges
Badges use `label-code` typography for a technical feel.
- **Pending:** Amber background (10% opacity) with Amber text.
- **Approved:** Emerald background (10% opacity) with Emerald text.
- **Reserved:** Blue background (10% opacity) with Blue text.
- **Missed:** Slate background (10% opacity) with Slate text.

### Seat Cards
The primary interface element.
- **Structure:** Seat ID in `label-code` at top-right, occupant name in `title-md`, and status badge at bottom-left.
- **State:** When a seat is "Available," the card border should thicken slightly and use the `tertiary_color`.

### Buttons
- **Primary:** Solid `secondary_color` with white text.
- **Secondary:** Outlined with `neutral_color` for less critical actions.
- **Ghost:** No border or background; used for "Cancel" or "Back" actions.

### Input Fields
- **Default:** White background, 1px border (#E2E8F0).
- **Focus:** 2px border using `secondary_color` with a subtle outer glow.

### Seat Map (Additional)
An interactive SVG or Grid layout showing floorplan proximity. Use circles for seats, color-coded by the status palette, with a 2px stroke to indicate "Selected" state.